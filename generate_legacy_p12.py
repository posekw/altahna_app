import base64
import os
import subprocess

# Paths
cert_pem = r"f:\Docler\coffee_calculator\correct_dist.pem"
key_file = r"f:\Docler\coffee_calculator\ios_dist_new.key"
p12_out = r"f:\Docler\coffee_calculator\ios_distribution_ultra_legacy.p12"
openssl_path = r"C:\Program Files\Git\usr\bin\openssl.exe"
password = "123456"

# Command
# --certpbe PBE-SHA1-3DES --keypbe PBE-SHA1-3DES --macalg SHA1 --nomaciter
cmd = [
    openssl_path, "pkcs12", "-export",
    "-inkey", key_file,
    "-in", cert_pem,
    "-out", p12_out,
    "-passout", f"pass:{password}",
    "-certpbe", "PBE-SHA1-3DES",
    "-keypbe", "PBE-SHA1-3DES",
    "-macalg", "SHA1",
    "-nomaciter"
]

print(f"Running command: {' '.join(cmd)}")
subprocess.run(cmd, check=True)

# Read binary and encode to base64
with open(p12_out, "rb") as f:
    p12_data = f.read()

b64_data = base64.b64encode(p12_data).decode("utf-8")

# Write base64 to file WITHOUT any extra stuff (no BOM, no newline)
with open(r"f:\Docler\coffee_calculator\p12_ultra_legacy_base64.txt", "w", encoding="utf-8") as f:
    f.write(b64_data)

print("P12 Ultra Legacy generated and Base64 saved.")
