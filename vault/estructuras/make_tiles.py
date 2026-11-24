"""Ruin textures (16x16, transparent bg), generated from scratch.

Style reference: dark teal brick wall + chunky slate blocks with green moss,
in three sizes (big / long / small) and two tones (light / dark).

  assets/map/structures/ruin_tiles.png       light -> collidable blocks
  assets/map/structures/ruin_tiles_dark.png  dark  -> background wall
  vault/estructuras/ruin_preview.png         composition preview

    python3 vault/estructuras/make_tiles.py

Sheet layout (8 columns, 2 rows, index = row*8+col):
  light 0 big  1 long  2 small  3 big dark  4 long dark  5 small dark  6 brick  7 brick dim
  mossy 8 big  9 long 10 small 11 big dark 12 long dark 13 small dark 14 brick top 15 brick var
"""
import random
import struct
import zlib

W = H = 16
T = (0, 0, 0, 0)

# Brick wall: near-black faces with teal grout.
GROUT_BRIGHT = (44, 100, 92, 255)
GROUT_DIM = (30, 70, 66, 255)
FACE_DARK = (16, 32, 36, 255)
FACE_MID = (22, 40, 44, 255)
FACE_LIGHT = (28, 48, 52, 255)

# Slate stone.
STONE_BASE = (92, 108, 120, 255)
STONE_DARK = (66, 80, 92, 255)
STONE_LIGHT = (114, 130, 142, 255)
STONE_EDGE = (32, 44, 56, 255)
STONE_BASE_D = (74, 86, 100, 255)
STONE_DARK_D = (52, 62, 76, 255)
STONE_LIGHT_D = (92, 106, 120, 255)
STONE_EDGE_D = (26, 36, 46, 255)

# Moss.
MOSS_M = (58, 150, 52, 255)
MOSS_L = (92, 196, 78, 255)
MOSS_H = (128, 226, 104, 255)
MOSS_D = (34, 94, 34, 255)

LIGHT_OUT = "assets/map/structures/ruin_tiles.png"
DARK_OUT = "assets/map/structures/ruin_tiles_dark.png"
PREVIEW_OUT = "vault/estructuras/ruin_preview.png"


def png(path, rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + b"".join(bytes(p) for p in r) for r in rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    data = (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 9))
            + chunk(b"IEND", b""))
    open(path, "wb").write(data)


def sheet(cells, cols):
    rows_n = (len(cells) + cols - 1) // cols
    out = [[T] * (cols * W) for _ in range(rows_n * H)]
    for i, tile in enumerate(cells):
        ox, oy = (i % cols) * W, (i // cols) * H
        for y in range(H):
            for x in range(W):
                out[oy + y][ox + x] = tile[y][x]
    return out


def new(fill=T):
    return [[fill for _ in range(W)] for _ in range(H)]


def put(g, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        g[y][x] = c


def fill(g, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            put(g, x, y, c)


def blobs(g, rng, x0, y0, x1, y1, colors, n, size=2):
    """Chunky 2x2 clusters: the blocky wear of the reference."""
    for _ in range(n):
        x, y = rng.randint(x0, x1), rng.randint(y0, y1)
        c = rng.choice(colors)
        for dy in range(size):
            for dx in range(size):
                put(g, x + dx, y + dy, c)


def moss(g, rng, x0, x1, y, coverage=0.75, depth=3, inner=False, specks=0):
    """Bright moss lip over a top edge, with a dark underside and drips."""
    for x in range(x0, x1 + 1):
        if rng.random() > coverage:
            continue
        d = rng.randint(1, depth)
        for k in range(d):
            put(g, x, y + k, MOSS_L if k == 0 else (MOSS_M if k < d - 1 else MOSS_D))
        if rng.random() < 0.45:
            put(g, x, y + d, MOSS_D)
        if rng.random() < 0.2:
            put(g, x, y + d + 1, MOSS_D)
    if inner:
        for _ in range(6):
            x, y2 = rng.randint(x0, x1), rng.randint(y + 2, 14)
            put(g, x, y2, rng.choice((MOSS_D, MOSS_M)))
    for _ in range(specks):
        put(g, rng.randint(x0, x1), rng.randint(y + 1, 14), rng.choice((MOSS_D, MOSS_L)))


def stone(seed, w=16, h=16, dark=False, mossy=False, y_bottom=15):
    """Chunky slate block: notched corners, dark edge, blocky wear, moss on top."""
    rng = random.Random(seed)
    base = STONE_BASE_D if dark else STONE_BASE
    deep = STONE_DARK_D if dark else STONE_DARK
    lit = STONE_LIGHT_D if dark else STONE_LIGHT
    edge = STONE_EDGE_D if dark else STONE_EDGE
    x0, x1 = (W - w) // 2, (W - w) // 2 + w - 1
    y0, y1 = y_bottom - h + 1, y_bottom
    g = new()
    fill(g, x0, y0, x1, y1, base)
    # notched corners: the reference blocks are rounded with 1-2 px bites
    for (cx, cy, sx, sy) in ((x0, y0, 1, 1), (x1, y0, -1, 1), (x0, y1, 1, -1), (x1, y1, -1, -1)):
        g[cy][cx] = T
        if rng.random() < 0.6:
            put(g, cx + sx, cy, T)
        if rng.random() < 0.6:
            put(g, cx, cy + sy, T)
    # edge: dark foot and sides, no shine
    for x in range(x0, x1 + 1):
        put(g, x, y1, deep)
        if g[y1][x] == T:
            put(g, x, y1, T)
    for y in range(y0, y1 + 1):
        put(g, x0, y, edge)
        put(g, x1, y, edge)
    for x in range(x0 + 1, x1):
        put(g, x, y1 - 1, deep)
    # blocky wear clusters
    blobs(g, rng, x0 + 2, y0 + 2, x1 - 3, y1 - 3, (deep, lit), 4, 2)
    blobs(g, rng, x0 + 1, y0 + 1, x1 - 2, y1 - 2, (deep,), 2, 1)
    if mossy:
        moss(g, rng, x0, x1, y0, 0.85, 3, True, 3)
        if rng.random() < 0.5:
            put(g, x0 + 1, y1 - 1, MOSS_D)
            put(g, x1 - 1, y1 - 1, MOSS_D)
    return g


def brick(seed, grout, mossy=False):
    """Four thin courses of bricks: dark faces, teal grout, matte."""
    rng = random.Random(seed)
    g = new(grout)
    for course in range(4):
        y0 = course * 4
        off = 0 if course % 2 == 0 else 4
        for bx in range(-1, 3):
            bx0 = bx * 8 + off
            for x in range(bx0 + 1, bx0 + 8):
                if 0 <= x < W:
                    for y in range(y0, y0 + 3):
                        face = FACE_MID if rng.random() < 0.75 else (
                            FACE_DARK if rng.random() < 0.5 else FACE_LIGHT)
                        put(g, x, y, face)
            # worn brick: a couple of darker pixels
            if rng.random() < 0.5:
                x = bx0 + rng.randint(2, 6)
                put(g, x, y0 + rng.randint(0, 2), FACE_DARK)
    if mossy:
        moss(g, rng, 0, W - 1, 0, 0.9, 4, True, 2)
        if rng.random() < 0.4:
            moss(g, rng, 0, 3, 8, 0.8, 2)
    return g


def darken(tile, r=0.52, g=0.58, b=0.62):
    out = []
    for row in tile:
        line = []
        for p in row:
            if p[3] == 0:
                line.append(p)
                continue
            line.append((int(p[0] * r), int(p[1] * g), int(p[2] * b), p[3]))
        out.append(line)
    return out


def light_tiles():
    return [
        stone(1, 16, 16),                       # 0 big
        stone(2, 16, 8, y_bottom=15),            # 1 long
        stone(3, 8, 8, y_bottom=15),             # 2 small
        stone(4, 16, 16, dark=True),             # 3 big dark
        stone(5, 16, 8, dark=True),              # 4 long dark
        stone(6, 8, 8, dark=True),               # 5 small dark
        brick(7, GROUT_BRIGHT),                  # 6 brick
        brick(8, GROUT_DIM),                     # 7 brick dim
        stone(9, 16, 16, mossy=True),            # 8 big mossy
        stone(10, 16, 8, mossy=True),            # 9 long mossy
        stone(11, 8, 8, mossy=True),             # 10 small mossy
        stone(12, 16, 16, dark=True, mossy=True),  # 11 big dark mossy
        stone(13, 16, 8, dark=True, mossy=True),   # 12 long dark mossy
        stone(14, 8, 8, dark=True, mossy=True),    # 13 small dark mossy
        brick(15, GROUT_BRIGHT, mossy=True),       # 14 brick top (moss)
        brick(16, GROUT_DIM, mossy=True),          # 15 brick top dim
    ]


def main():
    light = light_tiles()
    dark = [darken(t) for t in light]
    png(LIGHT_OUT, sheet(light, 8))
    png(DARK_OUT, sheet(dark, 8))

    # Preview: brick wall with a mossy stone foundation and a few ground stones.
    rng = random.Random(11)
    wid, hei = 24, 6
    tops = [3, 3, 4, 5, 5, 4, 3, 2, 2, 2, 3, 4, 4, 4, 5, 4, 3, 2, 2, 3, 4, 4, 3, 3]
    bricks = [6, 6, 7, 6, 7, 6, 6, 7]
    back = [[T] * (wid * W) for _ in range(hei * H)]
    front = [[T] * (wid * W) for _ in range(hei * H)]
    for tx in range(wid):
        height = tops[tx]
        for ty in range(hei - height, hei):
            if ty == hei - height:
                index = 14 if (tx + ty) % 3 else 15
            else:
                index = bricks[(tx * 3 + ty) % len(bricks)]
            for y in range(H):
                for x in range(W):
                    back[ty * H + y][tx * W + x] = dark[index][y][x]
    # Ground row: mossy stones in front (collidable in game).
    for tx in range(wid):
        if tops[tx] < 2:
            continue
        if tx % 6 == 0 or rng.random() < 0.18:
            index = (8, 11, 9, 12)[rng.randrange(4)]
            for y in range(H):
                for x in range(W):
                    front[(hei - 1) * H + y][tx * W + x] = light[index][y][x]
    for y in range(len(back)):
        for x in range(len(back[0])):
            if front[y][x][3] != 0:
                back[y][x] = front[y][x]
    png(PREVIEW_OUT, back)
    print("ok")


if __name__ == "__main__":
    main()
