for name in ["Add", "Max", "Rect", "Pong"]:
    mine = open(name + ".hack").read().split()
    official = open("Official" + name + ".hack").read().split()
    if mine == official:
        print(name, "-> MATCH (", len(mine), "lines )")
    else:
        print(name, "-> DIFFERENT")
        for i, (a, b) in enumerate(zip(mine, official), 1):
            if a != b:
                print("  first difference at line", i)
                print("  mine    :", a)
                print("  official:", b)
                break
        if len(mine) != len(official):
            print("  line counts:", len(mine), "vs", len(official))