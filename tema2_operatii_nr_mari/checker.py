import os
import subprocess
import re
import sys

TEST_FORMAT         = '%s..................................%s'
TEST_DIRECTORY      = 'Tests/'
PATH_TO_EXEC        = './calc'
PATH_TO_EXEC_FMT    = './calc %s \"%s\" %s'
RES_DIRECTORY       = TEST_DIRECTORY + 'Results/'

FAIL = 'Failed'
PASS = 'Passed'

def sorted_nicely(l): 
    """ Sort the given iterable in the way that humans expect.""" 
    convert = lambda text: int(text) if text.isdigit() else text 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

def runTest(testCase):

    ops = testCase.split()
    test_command = PATH_TO_EXEC_FMT % (ops[0], ops[1], ops[2])

    proc = subprocess.Popen(test_command, stdout=subprocess.PIPE, shell=True)
    (out, err) = proc.communicate()

    return out

def checkTestResult(resultFile, result):

    results = result.split()
    for i in range(0, 4):

        ref = resultFile.readline().strip()
        if ref != results[i]:
            return FAIL

    return PASS

if __name__=="__main__":

    total_points = 0

    if not os.path.isfile(PATH_TO_EXEC):
        print "The binary executable is missing.\nPlease rename the binary or compile it if you have forgotten."
        sys.exit()

    for testFile in sorted_nicely(os.listdir(TEST_DIRECTORY)):

        if os.path.isfile(TEST_DIRECTORY + testFile):
            tf = open(TEST_DIRECTORY + testFile, 'r')
            out = runTest(tf.readline())
            tf.close()

            rf = open(RES_DIRECTORY + testFile + '.out', 'r')
            res = checkTestResult(rf, out)
            rf.close()

            print TEST_FORMAT % (testFile, res)

            if res == PASS:
                total_points += 1

    print "\nTotal: %d/20" % total_points
