########################################################################
# Python-modules:
########################################################################
print "Inside S800_cpkg.py"
import numpy as np
import os
import Constants
from datetime import datetime, timedelta
########################################################################
# METROMS-modules:
########################################################################
from GlobalParams import *
from Params import *
from ModelRun_cpkg import *
########################################################################
#import time
#time.sleep(20)
########################################################################
# Set cpus for ROMS:
xcpu=4
ycpu=3
#xcpu=20
#ycpu=15

#xcpu=12
#ycpu=9

# Set cpus for CICE:
icecpu=12
#icecpu=300

#icecpu=24
#icecpu=108

# Choose a predefined ROMS-application:
app='S800' # Arctic-4km

start_date = datetime(2007,9,7,0)
#start_date = datetime(2007,07,29,0)
#start_date = datetime(2007,07,14,0)
end_date   = datetime(2007,12,31,0)

print start_date
print end_date

#S800params=Params(app,xcpu,ycpu,start_date,end_date,nrrec=0,cicecpu=icecpu,restart=False)
S800params=Params(app,xcpu,ycpu,start_date,end_date,nrrec=-1,cicecpu=icecpu,restart=True)

print "Model run"
modelrun=ModelRun_cpkg(S800params)

print GlobalParams.RUNDIR
print GlobalParams.COMMONPATH

print "Preprocess"
modelrun.preprocess()
print "Run preprocess"
modelrun.run_roms(Constants.MPI,Constants.DEBUG,Constants.VILJE) #24h hindcast
#modelrun.run_roms(Constants.DRY,Constants.NODEBUG,Constants.MET64) #24h hindcast
print "Run postprocess"
modelrun.postprocess()

