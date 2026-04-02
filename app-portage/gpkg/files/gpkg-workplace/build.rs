use std::process::Command;

fn main() {
    // Compile GResource files (glib resources)
    glib_build_tools::compile_resources(
        &["../../data"],
        "../../data/org.gentoo.PkgMngt.gresource.xml",
        "org.gentoo.PkgMngt.gresource",
    );

    // Path to the directory containing .po files
    let po_dir = std::path::Path::new("../../po");

    // Output directory for compiled .mo files
    let out_dir = std::env::var("OUT_DIR").unwrap();

    // Iterate over all files in the po directory
    for entry in std::fs::read_dir(po_dir).into_iter().flatten().flatten() {
        let path = entry.path();

        // Skip non-.po files
        if path.extension().and_then(|e| e.to_str()) != Some("po") {
            continue;
        }

        // Get the language code from the filename (e.g., "bg" from "bg.po")
        let stem = path.file_stem().unwrap().to_string_lossy().to_string();

        // Skip English; it's the source language
        if stem == "en" {
            continue;
        }

        // Define the output .mo file path inside OUT_DIR
        let mo_path = format!("{out_dir}/{stem}.mo");

        // Run msgfmt to compile .po → .mo
        let status = Command::new("msgfmt")
            .args(["-o", &mo_path, path.to_str().unwrap()])
            .status();

        match status {
            Ok(s) if s.success() => {
                println!("cargo:warning=Compiled locale: {stem}.mo");
            }
            _ => {
                println!(
                    "cargo:warning=msgfmt not found or failed for {stem}.po — translations will not be available"
                );
            }
        }
    }

    // Tell Cargo to rerun this script if any .po file changes
    println!("cargo:rerun-if-changed=../../po");
}
