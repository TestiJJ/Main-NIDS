import os
import shutil

release_dir = "NIDS_Release"
if os.path.exists(release_dir):
    shutil.rmtree(release_dir)
os.makedirs(release_dir)

# Files located inside the NIDS directory
files_to_include = [
    "NIDS/nids_bridge.py",
    "NIDS/requirements.txt",
    "NIDS/setup.bat",
    "NIDS/install.sh",
    "NIDS/README.md"
]

print("[*] Packaging files for distribution...")

for path in files_to_include:
    if os.path.exists(path):
        filename = os.path.basename(path)
        shutil.copy(path, os.path.join(release_dir, filename))
        print(f" [+] Copied: {filename}")
    else:
        print(f" [!] Warning: {path} not found, skipped.")

print(f"\n[+] Success! All release files are neatly organized inside the '{release_dir}' folder.")
