# EEG_Oddball_Shell

MATLAB, Psychtoolbox required

A simple oddball/p300 EEG program that works with both EGI and Biosemi systems. Displays letters for 1 s, interspersed with 1 s interstimulus intervals. The letter 'O' appears 80% of the time, and 'X' 20% of the time. Separate triggers are sent for each stimulus and recorded in EEG data (triggers 1 and 2, respectively). Note the string variable 'whichEEG', which runs EGI or Biosemi specific triggering code.

After preprocessing, the ERP should have a much larger positive peak from ~250 to 500 ms after the stimulus appears and the trigger is sent. This component difference will be particularly large in parietal brain regions (e.g. near #101 for EGI or A19 for Biosemi and surrounding electrodes).

This project is intended to demo live EEG recording for instruction of new EEG researchers, tour groups, or those exploring future use.
