import re
import sys

buf = []
result = ""
for line in open(sys.argv[1]):

    if len(buf) == 0:
        line = re.sub(r'^<a name=\"paths\"><\/a>$', r'', line.rstrip())
        line = re.sub(r'^## Paths$', r'', line.rstrip())
        line = re.sub(r'^#### Example HTTP response$', r'', line.rstrip())
        line = re.sub(r'^## (.*)$', r'# \1', line.rstrip())
        line = re.sub(r'^### (.*)$', r'## \1', line.rstrip())
        line = re.sub(r'^#### (.*)$', r'### \1', line.rstrip())
        line = re.sub(r'^##### (.*)$', r'> \1\n', line.rstrip())
        if (re.match(r'^```$', line.rstrip()) is None):
            result += (line + "\n")
        else:
            buf.append(line)
    else:
        if (re.match(r'^(POST|GET|PUT|DELETE) (/[a-z0-9{}_-]*)+$', line.rstrip()) is not None):
            result += ("`" + line.rstrip() + "`\n")
        elif (re.match(r'^json :$', line.rstrip()) is not None):
            result += "``` json\n"
            buf = []
        elif (re.match(r'^```$', line.rstrip()) is not None):
            buf = []
        else:
            result += "```\n" + line + "\n"
            buf = []


f = open(sys.argv[1], "w")
f.write(result)
f.close()
