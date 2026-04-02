//! StatusNotifierItem (systray) implementation via zbus.
//!
//! Implements the `org.kde.StatusNotifierItem` protocol on the session bus
//! for cross-DE compatibility (KDE Plasma, GNOME + AppIndicator, wlroots via waybar).
//!
//! Includes a `com.canonical.dbusmenu` interface for the right-click context menu.

use std::collections::HashMap;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, AtomicU32, AtomicU8, Ordering};
use std::sync::OnceLock;

use zbus::interface;
use zbus::object_server::SignalContext;
use zbus::zvariant::{OwnedValue, Value};

use gpkg_common::AppConfig;
use gpkg_common::types::SystrayIconMode;

// Import i18n
use crate::i18n;

/// Icon theme mode: 0 = Auto (symbolic/currentColor), 1 = Light (dark strokes), 2 = Dark (light strokes)
const ICON_MODE_AUTO: u8 = 0;
const ICON_MODE_LIGHT: u8 = 1;
const ICON_MODE_DARK: u8 = 2;

/// Shared state between the SNI D-Bus interface and the GTK application.
pub struct TrayState {
    pub updates_count: AtomicU32,
    pub needs_attention: AtomicBool,
    pub icon_mode: AtomicU8,
    pub session_conn: OnceLock<zbus::Connection>,
    pub action_tx: tokio::sync::mpsc::Sender<TrayAction>,
    pub action_rx: std::sync::Mutex<Option<tokio::sync::mpsc::Receiver<TrayAction>>>,
}

#[derive(Debug, Clone)]
pub enum TrayAction {
    ToggleWindow,
    ForceSync,
    Quit,
}

impl TrayState {
    pub fn new() -> Self {
        let (tx, rx) = tokio::sync::mpsc::channel(16);
        let initial_mode = AppConfig::load()
            .map(|c| c.systray_icon_mode.as_u8())
            .unwrap_or(ICON_MODE_AUTO);
        Self {
            updates_count: AtomicU32::new(0),
            needs_attention: AtomicBool::new(false),
            icon_mode: AtomicU8::new(initial_mode),
            session_conn: OnceLock::new(),
            action_tx: tx,
            action_rx: std::sync::Mutex::new(Some(rx)),
        }
    }

    pub fn take_action_rx(&self) -> Option<tokio::sync::mpsc::Receiver<TrayAction>> {
        self.action_rx.lock().unwrap().take()
    }

    pub async fn emit_new_icon(&self) {
        if let Some(conn) = self.session_conn.get() {
            let path = "/StatusNotifierItem";
            if let Ok(iface_ref) = conn
                .object_server()
                .interface::<_, StatusNotifierItem>(path)
                .await
            {
                let ctx = iface_ref.signal_context();
                let _ = StatusNotifierItem::new_icon(ctx).await;
            }
        }
    }

    fn icon_name_for_mode(&self) -> String {
        match self.icon_mode.load(Ordering::Relaxed) {
            ICON_MODE_LIGHT => "gpkg-dark-symbolic".to_string(),
            ICON_MODE_DARK => "gpkg-light-symbolic".to_string(),
            _ => "gpkg-symbolic".to_string(),
        }
    }

    fn attention_icon_name_for_mode(&self) -> String {
        match self.icon_mode.load(Ordering::Relaxed) {
            ICON_MODE_LIGHT => "gpkg-attention-dark-symbolic".to_string(),
            ICON_MODE_DARK => "gpkg-attention-light-symbolic".to_string(),
            _ => "gpkg-attention-symbolic".to_string(),
        }
    }

    fn icon_mode_label(&self) -> String {
        match self.icon_mode.load(Ordering::Relaxed) {
            ICON_MODE_LIGHT => i18n::i18n("Icon: Light theme"),
            ICON_MODE_DARK => i18n::i18n("Icon: Dark theme"),
            _ => i18n::i18n("Icon: Auto"),
        }
    }

    fn cycle_icon_mode(&self) {
        let current = self.icon_mode.load(Ordering::Relaxed);
        let next = (current + 1) % 3;
        self.icon_mode.store(next, Ordering::Relaxed);

        if let Ok(mut config) = AppConfig::load() {
            config.systray_icon_mode = SystrayIconMode::from_u8(next);
            if let Err(e) = config.save() {
                tracing::warn!("Failed to save systray icon mode to config: {e}");
            }
        }
    }
}

// ── StatusNotifierItem interface ──

pub struct StatusNotifierItem {
    state: Arc<TrayState>,
}

impl StatusNotifierItem {
    pub fn new(state: Arc<TrayState>) -> Self {
        Self { state }
    }
}

#[interface(name = "org.kde.StatusNotifierItem")]
impl StatusNotifierItem {
    #[zbus(property)]
    fn category(&self) -> String {
        "ApplicationStatus".to_string()
    }

    #[zbus(property)]
    fn id(&self) -> String {
        "org-gentoo-PkgMngt".to_string()
    }

    #[zbus(property)]
    fn title(&self) -> String {
        i18n::i18n("Gentoo Package Manager")
    }

    #[zbus(property)]
    fn status(&self) -> String {
        if self.state.needs_attention.load(Ordering::Relaxed) {
            "NeedsAttention".to_string()
        } else {
            "Active".to_string()
        }
    }

    #[zbus(property)]
    fn icon_name(&self) -> String {
        self.state.icon_name_for_mode()
    }

    #[zbus(property)]
    fn attention_icon_name(&self) -> String {
        self.state.attention_icon_name_for_mode()
    }

    #[zbus(property)]
    fn icon_theme_path(&self) -> String {
        "/usr/share/icons".to_string()
    }

    #[zbus(property)]
    fn icon_pixmap(&self) -> Vec<(i32, i32, Vec<u8>)> {
        let size: i32 = 16;
        let mut data = vec![0u8; (size * size * 4) as usize];
        let cx = size / 2;
        let cy = size / 2;
        let r = size / 2 - 1;
        for y in 0..size {
            for x in 0..size {
                let dx = x - cx;
                let dy = y - cy;
                if dx * dx + dy * dy <= r * r {
                    let idx = ((y * size + x) * 4) as usize;
                    data[idx] = 0xFF;
                    data[idx + 1] = 0x54;
                    data[idx + 2] = 0x48;
                    data[idx + 3] = 0x7A;
                }
            }
        }
        vec![(size, size, data)]
    }

    #[zbus(property)]
    fn tool_tip(&self) -> (String, Vec<(i32, i32, Vec<u8>)>, String, String) {
        let count = self.state.updates_count.load(Ordering::Relaxed);
        let subtitle = if count > 0 {
            i18n::i18n_f("{0} update(s) available", &[&count.to_string()])
        } else {
            i18n::i18n("System is up to date")
        };
        ("gpkg".to_string(), vec![], "gpkg".to_string(), subtitle)
    }

    #[zbus(property)]
    fn item_is_menu(&self) -> bool { false }

    #[zbus(property)]
    fn menu(&self) -> zbus::zvariant::OwnedObjectPath {
        zbus::zvariant::OwnedObjectPath::try_from("/MenuBar").unwrap()
    }

    #[zbus(property)]
    fn window_id(&self) -> i32 { 0 }

    fn activate(&self, _x: i32, _y: i32) {
        let _ = self.state.action_tx.try_send(TrayAction::ToggleWindow);
    }

    fn secondary_activate(&self, _x: i32, _y: i32) {
        let _ = self.state.action_tx.try_send(TrayAction::ToggleWindow);
    }

    fn scroll(&self, _delta: i32, _orientation: &str) {}
    
    #[zbus(signal)]
    async fn new_title(signal_ctxt: &SignalContext<'_>) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn new_icon(signal_ctxt: &SignalContext<'_>) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn new_attention_icon(signal_ctxt: &SignalContext<'_>) -> zbus::Result<()>;

    #[zbus(signal)]
    pub async fn new_tool_tip(signal_ctxt: &SignalContext<'_>) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn new_status(signal_ctxt: &SignalContext<'_>, status: &str) -> zbus::Result<()>;
}

// ── DBusMenu ──

const MENU_ROOT: i32 = 0;
const MENU_INFO: i32 = 1;
const MENU_SYNC: i32 = 2;
const MENU_OPEN: i32 = 3;
const MENU_THEME: i32 = 4;
const MENU_SEP: i32 = 5;
const MENU_QUIT: i32 = 6;

pub struct DbusMenu {
    state: Arc<TrayState>,
    revision: AtomicU32,
}

impl DbusMenu {
    pub fn new(state: Arc<TrayState>) -> Self {
        Self { state, revision: AtomicU32::new(1) }
    }

    fn item_props(&self, id: i32) -> HashMap<String, OwnedValue> {
        let mut props = HashMap::new();
        match id {
            MENU_ROOT => {
                props.insert("children-display".to_string(), Value::from("submenu").try_into().unwrap());
            }
            MENU_INFO => {
                let count = self.state.updates_count.load(Ordering::Relaxed);
                let label = if count > 0 {
                    i18n::i18n_f("{0} update(s)", &[&count.to_string()])
                } else {
                    i18n::i18n("System is up to date")
                };
                props.insert("label".to_string(), Value::from(label).try_into().unwrap());
                props.insert("enabled".to_string(), Value::from(false).try_into().unwrap());
            }
            MENU_SYNC => {
                props.insert("label".to_string(), Value::from(i18n::i18n("Force synchronization")).try_into().unwrap());
            }
            MENU_OPEN => {
                props.insert("label".to_string(), Value::from(i18n::i18n("Open gpkg")).try_into().unwrap());
            }
            MENU_THEME => {
                let label = self.state.icon_mode_label();
                props.insert("label".to_string(), Value::from(label).try_into().unwrap());
            }
            MENU_SEP => {
                props.insert("type".to_string(), Value::from("separator").try_into().unwrap());
            }
            MENU_QUIT => {
                props.insert("label".to_string(), Value::from(i18n::i18n("Quit")).try_into().unwrap());
            }
            _ => {}
        }
        props
    }
}

#[interface(name = "com.canonical.dbusmenu")]
impl DbusMenu {
    #[zbus(property)]
    fn version(&self) -> u32 { 3 }

    #[zbus(property)]
    fn text_direction(&self) -> String { "ltr".to_string() }

    #[zbus(property)]
    fn status(&self) -> String { "normal".to_string() }

    #[zbus(property, name = "IconThemePath")]
    fn icon_theme_path(&self) -> Vec<String> { vec![] }

    fn get_layout(
        &self,
        parent_id: i32,
        _recursion_depth: i32,
        _property_names: Vec<String>,
    ) -> zbus::fdo::Result<(u32, (i32, HashMap<String, OwnedValue>, Vec<zbus::zvariant::OwnedValue>))> {
        let rev = self.revision.load(Ordering::Relaxed);

        if parent_id != MENU_ROOT {
            return Ok((rev, (parent_id, self.item_props(parent_id), vec![])));
        }

        let children_ids = [MENU_INFO, MENU_SYNC, MENU_OPEN, MENU_THEME, MENU_SEP, MENU_QUIT];
        let children: Vec<OwnedValue> = children_ids.iter().map(|&id| {
            let child: (i32, HashMap<String, OwnedValue>, Vec<OwnedValue>) = (id, self.item_props(id), vec![]);
            Value::from(child).try_into().unwrap()
        }).collect();

        Ok((rev, (MENU_ROOT, self.item_props(MENU_ROOT), children)))
    }

    fn get_group_properties(&self, ids: Vec<i32>, _property_names: Vec<String>) -> zbus::fdo::Result<Vec<(i32, HashMap<String, OwnedValue>)>> {
        Ok(ids.iter().map(|&id| (id, self.item_props(id))).collect())
    }

    fn get_property(&self, id: i32, name: String) -> zbus::fdo::Result<OwnedValue> {
        let mut props = self.item_props(id);
        props.remove(&name).ok_or_else(|| zbus::fdo::Error::InvalidArgs(format!("No property {name} on item {id}")))
    }

    fn event(&self, id: i32, event_id: &str, _data: OwnedValue, _timestamp: u32) {
        if event_id != "clicked" { return; }
        match id {
            MENU_SYNC => { let _ = self.state.action_tx.try_send(TrayAction::ForceSync); }
            MENU_OPEN => { let _ = self.state.action_tx.try_send(TrayAction::ToggleWindow); }
            MENU_THEME => {
                self.state.cycle_icon_mode();
                let new_mode = self.state.icon_mode_label();
                tracing::info!("Tray icon theme cycled to: {new_mode}");

                if let Some(conn) = self.state.session_conn.get() {
                    let conn = conn.clone();
                    tokio::spawn(async move {
                        let path = "/StatusNotifierItem";
                        if let Ok(iface_ref) = conn.object_server().interface::<_, StatusNotifierItem>(path).await {
                            let ctx = iface_ref.signal_context();
                            let _ = StatusNotifierItem::new_icon(ctx).await;
                            let _ = StatusNotifierItem::new_attention_icon(ctx).await;
                        }
                    });
                }
            }
            MENU_QUIT => { let _ = self.state.action_tx.try_send(TrayAction::Quit); }
            _ => {}
        }
    }

    fn event_group(&self, events: Vec<(i32, String, OwnedValue, u32)>) -> zbus::fdo::Result<Vec<i32>> {
        for (id, event_id, data, timestamp) in events {
            self.event(id, &event_id, data, timestamp);
        }
        Ok(vec![])
    }

    fn about_to_show(&self, _id: i32) -> zbus::fdo::Result<bool> {
        self.revision.fetch_add(1, Ordering::Relaxed);
        Ok(true)
    }

    fn about_to_show_group(&self, ids: Vec<i32>) -> zbus::fdo::Result<(Vec<i32>, Vec<i32>)> {
        self.revision.fetch_add(1, Ordering::Relaxed);
        Ok((ids, vec![]))
    }

    #[zbus(signal)]
    async fn items_properties_updated(
        signal_ctxt: &SignalContext<'_>,
        updated_props: &[(i32, HashMap<String, OwnedValue>)],
        removed_props: &[(i32, Vec<String>)],
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn layout_updated(signal_ctxt: &SignalContext<'_>, revision: u32, parent: i32) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn item_activation_requested(signal_ctxt: &SignalContext<'_>, id: i32, timestamp: u32) -> zbus::Result<()>;
}

// ── Startup ──

pub async fn start_tray(state: Arc<TrayState>) -> anyhow::Result<zbus::Connection> {
    let sni = StatusNotifierItem::new(state.clone());
    let menu = DbusMenu::new(state.clone());

    let conn = zbus::ConnectionBuilder::session()?
        .name("org.kde.StatusNotifierItem-gpkg")?
        .serve_at("/StatusNotifierItem", sni)?
        .serve_at("/MenuBar", menu)?
        .build()
        .await?;

    let _ = state.session_conn.set(conn.clone());

    let proxy = zbus::Proxy::new(
        &conn,
        "org.kde.StatusNotifierWatcher",
        "/StatusNotifierWatcher",
        "org.kde.StatusNotifierWatcher",
    )
    .await?;

    match proxy.call_method("RegisterStatusNotifierItem", &("org.kde.StatusNotifierItem-gpkg",)).await {
        Ok(_) => tracing::info!("Systray: registered with StatusNotifierWatcher"),
        Err(e) => tracing::warn!("Systray: watcher registration failed (DE may not support SNI): {e}"),
    }

    Ok(conn)
}
