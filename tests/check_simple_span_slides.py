from pathlib import Path
import csv
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
source = (root / "slides/02_M3.qmd").read_text()

def page(slide_id):
    section = next(s for s in re.split(r"(?=^## )", source, flags=re.M)
                   if "{#" + slide_id + " " in s.splitlines()[0])
    return ET.fromstring("".join(re.findall(r"```\{=html\}\n(.*?)\n```", section, re.S)))

study = page("simple-span")
words = ["".join(s.itertext()) for s in study.find(".//*[@class='m3-real-frames']")]
test = page("which-item-was-in-the-middle")
frames = list(test.find(".//*[@class='m3-real-frames']"))
options = [s.text for s in test.find(".//*[@class='m3-real-options']")]
assert len(words) == len(frames) == 6
target = words[next(i for i, frame in enumerate(frames) if frame.text == "?")]
groups = list(page("response-categories").find(".//*[@class='m3-response-categories']"))
switch = page("response-categories").find(".//*[@class='m3-category-stages']/div")
assert switch.get("data-fragment-index") == "4" and "fade-out" in switch.get("class")
group_words = [g.find(".//*[@class='m3-category-items']").text.split(", ") for g in groups]
assert group_words[0] == [target]
assert set(group_words[1]) == set(words) - {target}
assert set(group_words[2]) == set(options) - set(words)
assert [len(g) for g in group_words] == [1, 5, 4]
assert len(options) == len(set(options)) == sum(map(len, group_words))
assert sum(e.get("data-autoslide") == "900" for e in study.iter()) == 5
assert sum(e.get("data-autoslide") == "100" for e in study.iter()) == 5
assert sum(e.get("data-autoslide") == "1100" for e in study.iter()) == 1
with (root / "data/m3_simple_span.csv").open() as f:
    rows = list(csv.DictReader(f))
data = next(r for r in rows if r["id"] == "20_openset"
            and r["setsize"] == "6" and r["n_other"] == "5" and r["n_npl"] == "4")
overview = page("response-categories")
combinations = overview.find(".//*[@class='m3-test-combinations']")
displayed = {tuple(int(re.search(r"\d+", item.text)[0]) for item in row)
             for row in combinations}
expected = {tuple(int(r[k]) for k in ("n_corr", "n_other", "n_npl"))
            for r in rows if int(r["setsize"]) == 6}
assert displayed == expected
colored = overview.find(".//*[@class='m3-real-options']")
for item in colored:
    category = item.get("class").removeprefix("m3-test-")
    index = {"correct": 0, "other": 1, "npl": 2}[category]
    assert item.text in group_words[index]
assert overview.find(".//*[@class='m3-data-example fragment']").get("data-fragment-index") == "6"
assert '## From responses to data {#test-option-composition' not in source
for entry in overview.iter("div"):
    code, value = entry.find("code"), entry.find("strong")
    if code is not None and value is not None and code.text in ("setsize", "corr", "other", "npl", "n_corr", "n_other", "n_npl"):
        assert value.text == data[code.text]
prepared = next(s for s in re.split(r"(?=^## )", source, flags=re.M)
                if "{#preparing-simple-span-data " in s.splitlines()[0])
assert 'summarise(corr = sum(response_type == "correct")' in prepared
for row in rows[:3]:
    assert all(str(row[k]) in prepared for k in ("id", "exp", "setsize", "corr", "other", "npl", "n_corr", "n_other", "n_npl"))
print("Study, cue, category membership, timing, and displayed data are consistent.")
