import gdb


class FrameSizes(gdb.Command):
    """frame-sizes [N]: print stack bytes per frame (first N, default 30) plus totals by function."""

    def __init__(self):
        super().__init__("frame-sizes", gdb.COMMAND_STACK)

    def invoke(self, arg, from_tty):
        limit = int(arg) if arg else 30
        f, i, total = gdb.newest_frame(), 0, 0
        by_func = {}
        while f is not None and f.older() is not None:
            older = f.older()
            size = int(older.read_register("sp")) - int(f.read_register("sp"))
            name = f.name() or "??"
            cnt, byt = by_func.get(name, (0, 0))
            by_func[name] = (cnt + 1, byt + size)
            total += size
            if i < limit:
                print(f"#{i:<5} {size:>8} B  {name}")
            f, i = older, i + 1
        print(f"\n{i} frames, {total} bytes total\n\nBy function (sorted by bytes):")
        for name, (cnt, byt) in sorted(by_func.items(), key=lambda kv: -kv[1][1])[
            : max(limit // 2, min(limit, 10))
        ]:
            print(f"{byt:>10} B  {cnt:>7} frames  {byt // cnt:>6} B/frame  {name}")


FrameSizes()
