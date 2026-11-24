# SPDX-License-Identifier: GPL-2.0-or-later
from pathlib import Path
import re

def discover():
    return sorted({p.resolve() for p in Path('/sys/bus/pci/devices').glob('*') if (p/'driver').resolve().name == 'amdgpu'})

def select(pci='auto'):
    devices = discover()
    if pci == 'auto' and len(devices) == 1:
        return devices[0]
    for p in devices:
        if p.name == pci:
            return p
    raise ValueError('Select an AMDGPU PCI address: ' + ', '.join(p.name for p in devices))
