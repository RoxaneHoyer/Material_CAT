################################################################################

Readme file for Audiometry

Files include:
Audiometry.exp
Audiometry.sce
Audiometry.pcl
SUBROUTINE_FileSize.pcl
SUBROUTINE_SPL_Calibration.pcl
SUBROUTINE_Threshold_Test_Bekesy.pcl
SUBROUTINE_Balance_Test_Bekesy.pcl
SUBROUTINE_Vol2SPL.pcl
SUBROUTINE_SPL2Vol.pcl
SUBROUTINE_Vol2dBHL.pcl
SUBROUTINE_dBHL2Vol.pcl
SUBROUTINE_Convert_Volumes.pcl
SUBROUTINE_Specify_Sound_Volume.pcl
SUBROUTINE_Threshold_Check.pcl
SUBROUTINE_Balance_Check.pcl
README.txt
JDoe_balances_Example.txt
JDoe_thresholds_Example.txt
Normal_balances.txt
Normal_balances_Example.txt
Normal_thresholds.txt
Normal_thresholds_Example.txt
SPL_Calibration_Example.txt
250.wav
500.wav
1000.wav
2000.wav
4000.wav

################################################################################

Summary:

The Audiometry Utility Package is a collection of utilities that facilitate calibration of your audio system and obtaining perceptual thresholds for your subjects. After using the Audiometry Utility Package you should  be 
well on the way to being able to specify the intensity of your stimuli in SPL, SL, or nHL from within your Presentation experiment. The utilities include:

1. SPL Calibration - a single tone is played repeatedly to allow calibration of Sound Pressure Level using an SPL measuring device.

2. Threshold Test (Bekesy) - implements a modified Bekesy procedure for determining hearing thresholds. 

3. Balance Test (Bekesy) - implements a modified Bekesy procedure for determining hearing balance.

4. Convert Volumes - provides a quick demonstration of how to convert between different volume units, including dB SPL, dB nHL and dB SL.

5. Specify Sound Volume - allows user to enter a sound volume in dB SPL, dB nHL or dB SL, then plays back a tone at that volume.

6. Threshold Check - performs a quick check of system volume levels to ensure that sound intensities have been appropriately adjusted, or provides a quick check of a subjects hearing thresholds relative to previous measurements or normal levels.

7. Balance Check - performs a quick check of system balance levels to ensure that sound intensities have been appropriately balanced, or provides a quick check of a subjects hearing balance relative to previous measurements or normal levels. 

The Audiometry menu also offers one more option: Toggle Example/New. This allows the user to toggle between using the Example files provided as input and output, and typing in a new subject name to generate a new set of files.

All of the utilities in Audiometry are coded as subroutines, with clearly delineated code portions in the Audiometry.sce and Audiometry.pcl files. This makes these utilities easy to cut and paste into other programs.

################################################################################

Details and Tips For Using These Utilities:

--------------------------------------------------------------------------------

1. SPL Calibration 

A single tone is played repeatedly at a particular speaker or combination of speakers while the experimenter measures the Sound Pressure Level. When the measurement has been obtained, the experimenter stops the test and enters the measurement at the prompt. Data from all tests are written to a file called "SPL_Calibration.txt", which is used later to convert between SPL and Presentation Volume settings. Currently a linear relationship is assumed between SPL and Volume. This could be replaced with more complex curve fitting or table lookup strategies if desired. 

The sounds, volumes and speakers tested are easily modified in the section of the Audiometry.pcl file labeled SPL_Calibration. 

--------------------------------------------------------------------------------

2. Threshold Test (Bekesy) 

Each sound-ear combination constitutes a "test" in the code. Each test is made up of multiple "sequences", each of which comprises either ascending or descending volume values. The subject is asked to press a button during a sequence when the sounds disappears or reappears. The final threshold estimate is the average of the last NUM_LOOPS_AVE pairs of descending and ascending values. For example, when NUM_LOOPS_AVE = 1, ascending and descending thresholds will be averaged from a single reversal.

The sounds and speakers tested are easily modified in the section of the Audiometry.pcl file labeled Threshold_Test_Bekesy. Also, the variable RANDOMIZE can used to toggle whether the tests are randomize or not.

In SUBROUTINE_Threshold_Test_Bekesy.pcl, there are several parameters that can be modified as desired:

Volume Increments (DELTA_VOL):
The volume changes used in the set of descending and ascending sequences for a test of a single sound-ear combination can be modified in the DELTA_VOL array. The last two values in DELTA_VOL will be repeated NUM_LOOPS_AVE times for calculating the average threshold. Modifications to DELTA_VOL must conform to these constraints: 
1) array must contain at least two values, while any number of values greater than or equal to 2 can be used (***NOTE: remember to change the array size index appropriately ***)
2) values must alternate between negative (descending) and positive (ascending)
3) values should be between -1.0 and 1.0
Other notes on making modifications:
1) step size should in general decrease from start to finish in order to get the best accuracy on the final measurements
2) the last two values do not have to be the same step size
3) the array can start with descending or ascending (negative or positive), but it is important to make sure the initial volume STARTVOLUME is set appropriately (i.e., an audible level if descending, inaudible if ascending).

NUM_LOOPS_AVE:
This value controls the number of descending plus ascending loops over which to calculate the average threshold volume. NUM_LOOPS_AVE can have integer values greater than zero.

RESPONSE_WINDOW_START:
This value controls how button presses (responses) are associated with stimuli. RESPONSE_WINDOW_START is the time (in msec) relative to the start of a sound pulse after which a response is associated with that pulse. If the response occurs less than RESPONSE_WINDOW_START msec after the pulse, it is associated with the previous pulse. RESPONSE_WINDOW_START should be greater than or equal to 0 and less than AUDTRIAL_DURATION.

HYSTERESIS:
This determines the number of volume increments in the same direction after a button press. This is used to avoid changing directions between ascending and descending sequences too abruptly. Changes near the threshold may cause confusion for the subject, so the pulses continue moving in the same direction for HYSTERESIS pulses, then turn around and start coming back. HYSTERESIS can have integer values greater than or equal to zero.

--------------------------------------------------------------------------------

3. Balance Test (Bekesy) 


The Balance scenario measures the subject's perception of the audio balance of the system by slowly panning a sound from left to right, asking the subject to press the button when the sounds have equal intensity in each ear. Each sound constitutes a "test" in the code. Each test is made up of multiple "sequences", each of which comprises either left-to-right or right-to-left variation in pan values. The final pan estimate is the average of the last NUM_LOOPS_AVE pairs of left-to-right and right-to-left values. For example, when NUM_LOOPS_AVE = 1, left-to-right and right-to-left values will be averaged from a single reversal.

The sounds tested are easily modified in the section of the Audiometry.pcl file labeled Balance_Test_Bekesy.

In SUBROUTINE_Balance_Test_Bekesy.pcl, there are several parameters that can be modified as desired:

Pan Increments (DELTA_PAN):
The pan changes used in the set of left-to-right and right-to-left sequences for a test of a single sound can be modified in the DELTA_PAN array in the pcl file. The last two values in DELTA_PAN will be repeated NUM_LOOPS_AVE times for calculating the average balance. Modifications to DELTA_PAN must conform to these constraints: 
1) array must contain at least two values, while any number of values greater than or equal to 2 can be used (***NOTE: remember to change the array size index appropriately ***)
2) values must alternate between negative (right-to-left) and positive (left-to-right)
3) values should be between -1.0 and 1.0
Other notes on making modifications:
1) step size should in general decrease from start to finish in order to get the best accuracy on the final measurements
2) the last two values do not have to be the same step size
3) the array can start with left-to-right or right-to-left (positive or negative), but it is important to make sure the initial volume START_PAN is set appropriately (i.e., start on left (negative) if left-to-right, start on right (positive) if right-to-left).

NUM_LOOPS_AVE:
This value controls the number of left-to-right plus right-to-left loops over which to calculate the average pan value. NUM_LOOPS_AVE can have integer values greater than zero.

RESPONSE_WINDOW_START:
This value controls how button presses (responses) are associated with stimuli. RESPONSE_WINDOW_START is the time (in msec) relative to the start of a sound pulse after which a response is associated with that pulse. If the response occurs less than RESPONSE_WINDOW_START msec after the pulse, it is associated with the previous pulse. RESPONSE_WINDOW_START should be greater than or equal to 0 and less than AUDTRIAL_DURATION.

HYSTERESIS:
This determines the amount by which the pan value is changed before changing directions for the next sequence.

--------------------------------------------------------------------------------

4. Convert Volumes 

--------------------------------------------------------------------------------

5. Specify Sound Volume 

The sound and speakers tested are easily modified in the section of the Audiometry.pcl file labeled Specify_Sound_Volume.

--------------------------------------------------------------------------------

6. Threshold Check 

A set of sounds is played back at various volumes in specified speakers. These volumes are set by combining values read from a threshold file with values in the DELTA_VOL parameter. The input file should have volume levels corresponding to auditory thresholds. See below for input file format and details on DELTA_VOL. The user is asked to press a button whenever a sound is heard. Output to the terminal pane of the status window lets the experimenter know the results of each test, which include CORRECT responses (volume above threshold + button press OR volume below threshold + no button press) and WRONG responses (volume above threshold + no button press OR volume below threshold + button press). If there are no WRONG responses, then the system volume is assumed to be set at a level that corresponds relatively closely with when the thresholds were initially determined.

The file format includes: 1) a header line and 2) three tab separated columns, which are description, speaker code and volume.

Example:
SOUND	SPKR_CD	THRESHOLD
250 Hz	1	0.35
500 Hz	1	0.37
250 Hz	2	0.38
500 Hz	2	0.42
250 Hz	3	0.40
500 Hz	3	0.36

The file format for the input conforms with that of the output files created by the Threshold Test (Bekesy) utility. Threshold values will vary between 0 and 1.

The sounds and speakers tested are easily modified in the section of the Audiometry.pcl file labeled Threshold_Check.

In SUBROUTINE_Threshold_Check.pcl, there are several parameters that can be modified as desired:

Subroutine getValidTests_tc:
The code contains a subroutine that implements the file readings and comparisons.

DELTA_VOL:
Values added to threshold volumes. These should range from -100 to 100 dB. Postive values will result in sounds over threshold, meaning that the subject will be expected to press the button. Negative values, on the other hand, will result in sounds below the threshold, meaning the subject will be expected to not press the button. If the sum of the threshold and delta value is out of bounds (less than 0.0 or greater than 1.0), it will be set to either the minimum or maximum value. ***NOTE: remember to change the array size index appropriately.***

SUBJECT_TEST:
When set to true, displays only fixation cross during tests. When false, displays test info (sound description, volume). 

--------------------------------------------------------------------------------

7. Balance Check 

A set of sounds is played back at various pan values corresponding to more or less intensity in the left and right ears. These pans are set by combining values read from a balance file with values in the DELTA_PAN array, which is created using the PAN_COUNT parameter. The input file should have pan levels corresponding to balanced sounds. See below for input file format and details on PAN_COUNT. The user is asked to press the left mouse button if a sound is louder in the left ear, the right mouse button if the sound is louder in the right ear. Output to the terminal pane of the status window lets the experimenter know the results of each test, which include CORRECT responses (pan value and button press agree), WRONG responses (pan value and button press do not agree), and NO PRESS responses. If there are no WRONG responses, then the system pan is assumed to be set at a level that corresponds closely with when the balances were initially determined.

The file format includes: 1) a header line and 2) two tab separated columns, which are description and pan.

Example:
SOUND	PAN
250 Hz	0.03
500 Hz	-0.01

The file format for the input conforms with that of the output files created by the Balance Test (Bekesy) utility. Pan values will vary between -1 and 1.

The sounds tested are easily modified in the section of the Audiometry.pcl file labeled Balance_Check.

In SUBROUTINE_Balance_Check.pcl, there are several parameters that can be modified as desired:

Subroutine getValidTests_bc:
The code contains a subroutine that implements the file readings and comparisons.

PAN_COUNT:
Sets the number of pan tests to be run on each sound. The maximum delta pan values will be half this number divided by 100. E.g., if PAN_COUNT = 4, DELTA_PAN is an array of 4 values, including -0.02, -0.01, 0.01 and 0.02. If PAN_COUNT = 6, DELTA_PAN is an array of 6 values, including -0.03, -0.02, -0.01, 0.01, 0.02 and 0.03. Postive values will result in sounds with greater intensity in the right ear, while negative values will result in sounds with greater intensity in the left ear. If the sum of the pan and delta value is out of bounds (less than -1.0 or greater than 1.0), it will be set to either the minimum or maximum value. PAN_COUNT should always be an even number. The array DELTA_PAN is randomly shuffled before the testing begins.

SUBJECT_TEST:
When set to true, displays only fixation cross during tests. When false, displays test info (sound description, pan). 
