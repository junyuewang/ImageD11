from __future__ import print_function

import os, sys, unittest, importlib
sys.path.insert(0,".")

modules = [
    "test_clean_mask",
    "test_closest_vec",
    "test_score_gvec_z",
    "test_sym_u",
    "testcol",
    "test_misori",
    "testlattice",
    "test_indexing",
    "test_localmaxlabel",
#not a unittest    "test_overlapimage",
    "test_sparse_image",
    "test_cImageD11",
    "gv_general.test_gv_general",
    "testcolumnfile",
    "test_put_incr",
    "testscale",
    "test_ubito",
    "test_uncomputegv",
    "test_transform",
    "twinprob.test_twin",
    "testcolfile2db.testcolfile2db",
    "ken_simul.testken",
    "testconnectedpixels.testconnectedpixels",
    "testlabelimage.testlabelimage",
    "test_compress_duplicates",
    "eps_sig.test_eps",
    "test_finite_strain",
]

if "all" in sys.argv:
    modules += ["index_demos.generate_gv",
                "test_index_unknown.test_index_unknown",
                "peaksearchtiftest.make_test_data",
                "test_mmo.make_test_data_mmo",
    ]
else:
    print ("Add \"all\" to command line to run all tests")
HERE = os.getcwd()
print( "HERE",HERE )

for M in modules:
    os.chdir(HERE)
    print("Running suite for ",M)
    if M.find(".")>-1:
        path = M.split(".")
        for direc in path[:-1]:
            os.chdir( direc )
        M = path[-1]
    try:
        MOD = importlib.import_module(M)
    except:
        print( "Error importing",M )
        print("Current folder is",os.getcwd() )
        print("Try removing .pyc files or __pycache__ folder if there is one")
        print("---RAISING----")
        raise
    mySuite = unittest.loader.findTestCases( MOD )
    runner = unittest.TextTestRunner()
    try:
        runner.run(mySuite)
    except:
        raise
