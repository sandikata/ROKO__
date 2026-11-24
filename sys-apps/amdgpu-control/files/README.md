# amdgpu-control

Local Gentoo package; no distfiles. GPL-2.0-or-later (proposed distribution license).
Configuration: /etc/amdgpu-control.conf (INI, shared by both init systems).
OpenRC /etc/conf.d/amdgpu-control only selects the configuration path.
Default configuration does not write GPU settings. Enable sections explicitly.
The RX 6750 XT example is hardware-specific; do not use it on other GPUs.
Stop LACT/CoreCtrl and any local controller before starting this service.
The monitor is read-only; --list-devices and --device PCI select hardware.
GFXOFF requires debugfs and suitable privileges. Missing sensors show N/A.
Performance settings are applied at startup, not periodically enforced. No VRAM
Overdrive. Fan control restores automatic PWM on normal exit or Python exception;
SIGKILL or a hardware failure may prevent cleanup. Performance settings are not
rolled back on stop or partial failure. Reboot to restore driver defaults.
Do not enable at boot until tested manually. No real hardware or Portage tests
have been performed on this package.
