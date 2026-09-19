import sys

PATH = sys.argv[1] if len(sys.argv) > 1 else "cla64_flat.v"

def carry(k):
    """c[k] = g[k-1] + p[k-1].g[k-2] + ... + p[k-1]...p[0].cin"""
    terms = []
    for j in range(k - 1, -1, -1):
        prod = [f"p[{m}]" for m in range(k - 1, j, -1)] + [f"g[{j}]"]
        terms.append("(" + " & ".join(prod) + ")")
    terms.append("(" + " & ".join([f"p[{m}]" for m in range(k - 1, -1, -1)] + ["cin"]) + ")")
    return f"  assign #(2) c[{k}] = " + " | ".join(terms) + ";"

block = "\n".join(carry(k) for k in range(1, 65))

src = open(PATH).read()
if "assign #(2) c[1]" in src:
    sys.exit("already generated -- restore the stub first")

out, done_c, done_sum = [], False, False
for line in src.split("\n"):
    if "TODO" in line and "c[1] through c[64]" in line:
        out.append(block); done_c = True
    elif "TODO" in line and "sum" in line and "p ^" in line:
        out.append("  assign #(2) sum = p ^ {c[63:1], cin};"); done_sum = True
    else:
        out.append(line)

if not (done_c and done_sum):
    sys.exit(f"anchor not found (carries={done_c}, sum={done_sum}) -- file not modified")

open(PATH, "w").write("\n".join(out))
print("ok: 64 carry equations + sum assign written")