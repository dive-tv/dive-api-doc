import re
import sys

buf = []
result = ""
includes = "---\nincludes:\n"
for line in open(sys.argv[1]):

     #Adding principal title with a to find it in the document
    if (re.match(r'^# (.*)$', line.rstrip()) is not None):
        a_link = re.sub("# ","", line.rstrip())
        line = re.sub(r"# \*\*","## **", line.rstrip())
        line = line + "<a name='" + a_link + "'></a>\n"

    #Adding docs to includes 
    if (re.match(r'^[^\S]+-[^\S]\[.*\]\(docs/.*\.md.*\).*$', line.rstrip()) is not None):
        new_line = re.sub(r"^[^\S]+-[^\S]\[.*\]\(docs/", "", line.rstrip())
        new_line = re.sub(r"\.md.*\).*$", "", new_line.rstrip())
        includes += " - " + new_line + "\n"

    if (re.match(r'^.*\[.*\]\(.*\.md#.*\).*$', line.rstrip()) is not None):
        
        #split name of document to add it at includes
        new_line = re.sub(r"^.*\[.*\]\([docs/]*", "", line.rstrip())
        new_line = re.sub(r"\.md#.*\).*$", "", new_line.rstrip())

        if (new_line not in includes):
            includes += " - " + new_line + "\n"
        
        line = re.sub(r"]\(.*\.md", "](", line.rstrip())

    elif (re.match(r'^.*\[.*\]\(docs/.*\.md\).*$', line.rstrip()) is not None):
        line = re.sub(".md", "", line.rstrip())
        line = re.sub(r"]\(docs/", "](#", line.rstrip())
    elif (re.match(r'^.*\[.*\]\(.*\.md\).*$', line.rstrip()) is not None):
        line = re.sub(".md", "", line.rstrip())
        line = re.sub(r"]\(", "](#", line.rstrip())
    
    if (re.match(r'^(.*)(\|+.*)+(.*)$', line.rstrip()) is not None and not ("\n" in line)):
        line += "\n"
    elif (re.match(r'^(.*)(\|+.*)+(.*)$', line.rstrip()) is None):
        line += "\n"

    result += (line)

includes += "\ntoc_footers:\n - <a href='http://dive.tv/'>2018 Dive all rights reserved</a>\n\nsearch: true\n\n---\n\n"

f = open(sys.argv[1], "w")
if ("_README.md" in sys.argv[1]):
    f.write(includes)
f.write(result)
f.close()
