import re
import sys
def remove_comments(text):
    """ remove c-style comments.
        text: blob of text with comments (can include newlines)
        returns: text with comments removed
    """
    pattern = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|//[^\r\n]*$)"
    regex = re.compile(pattern, re.VERBOSE|re.MULTILINE|re.DOTALL)
    def _replacer(match):
        # if the 2nd group (capturing comments) is not None,
        # it means we have captured a non-quoted (real) comment string.
        if match.group(2) is not None:
            return "" # so we will return empty to remove the comment
        else: # otherwise, we will return the 1st group
            return match.group(1) # captured quoted-string
    return regex.sub(_replacer, text)

def remove_spaces(text):
  newtext = ""
  linelist = text.split('\n')
  for line in linelist:
    if len(line.strip())>0:
      newtext = newtext + line.strip() + "\n"
  return newtext


filename = sys.argv[1]
code_w_comments = open(filename).read()
code_wo_comments = remove_comments(code_w_comments)
code_wo_spaces = remove_spaces(code_wo_comments)

fh = open(filename + "_nospcm_", "w")
fh.write(code_wo_spaces)
fh.close()

