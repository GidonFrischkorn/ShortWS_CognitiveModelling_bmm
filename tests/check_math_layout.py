from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
source = r"""$$
\begin{aligned}
A(\mathrm{correct}) &= b+a+c \\
A(\mathrm{paired\ distractor}) &= b+fa+fc \\
A(\mathrm{NPL}) &= b
\end{aligned}
$$

$$P(i)=\frac{\exp(A_i)}{\sum_j\exp(A_j)}$$
"""
command = ["quarto", "pandoc", "--from=markdown", "--to=html5", "--mathml"]
original = subprocess.check_output(command, input=source, text=True)
filtered = subprocess.check_output(
    command + ["--lua-filter=" + str(root / "slides/math-layout.lua")],
    input=source, text=True,
)
before = ET.fromstring("<root>" + original + "</root>")
after = ET.fromstring("<root>" + filtered + "</root>")
ns = {"m": "http://www.w3.org/1998/Math/MathML"}
for cell in after.findall(".//m:mtd", ns):
    strut = cell[0]
    assert strut.tag.endswith("mpadded") and strut.get("width") == "0"
    assert strut.get("aria-hidden") == "true"
    assert strut.find("m:mphantom", ns) is not None
    cell.remove(strut)
assert [ET.tostring(m) for m in before.findall(".//m:math", ns)] == [
    ET.tostring(m) for m in after.findall(".//m:math", ns)
], "Formula contents changed"
print("Aligned cells have invisible height references; formula contents are unchanged.")
