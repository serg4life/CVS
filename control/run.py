#!/usr/bin/env python3

from os import environ, name
from pathlib import Path
from subprocess import check_call
from vunit import VUnit

ROOT = Path(__file__).resolve().parent
lib_dir = ROOT / "shared"
lib_dir.mkdir(exist_ok=True)

VU = VUnit.from_argv()
VU.add_vhdl_builtins()
VU.add_verification_components()

LIB = VU.add_library("lib")
LIB.add_source_files([
    ROOT / "src" / "*.vhd",
    ROOT / "test" / "*.vhd",
])

check_call(["gcc", "-fPIC", "-shared", str(ROOT / "c" / "cosim_parameters.c"), "-o", str(lib_dir / "libcosim.so")])

if name == 'posix':
    LDPATH = environ.get("LD_LIBRARY_PATH")
    environ["LD_LIBRARY_PATH"] = (LDPATH + ":" if LDPATH else '') + "."

VU.main()
