import random

N = 200          # 测试次数
SEED = 0x12345678
OUT = "vectors.txt"

random.seed(SEED)

acc = 0
lines = []
for _ in range(N):
    a = random.randint(-128, 127)
    b = random.randint(-128, 127)
    acc += a * b
    lines.append(f"{a} {b} {acc}\n")

with open(OUT, "w") as f:
    f.writelines(lines)

print(f"[gen_vectors] wrote {N} vectors to {OUT}, final acc={acc}")
