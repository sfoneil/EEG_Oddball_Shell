function EEG_Oddball_Shell()
%A simple oddball/p300 EEG program that works with both EGI and Biosemi systems.
%   Displays letters for 1 s, interspersed with 1 s interstimulus intervals.
%   The letter 'O' appears 80% of the time, and 'X' 20% of the time.
%   Separate triggers are sent for each stimulus and recorded in EEG data
%   (triggers 1 and 2, respectively). Note the string variable 'whichEEG',
%   which runs EGI or Biosemi specific triggering code.
%
%   After preprocessing, the ERP should have a much larger positive peak
%   from ~250 to 500 ms after the stimulus appears and the trigger is sent.
%   This component difference will be particularly large in parietal brain
%   regions (e.g. near #101 for EGI or A19 for Biosemi and surrounding
%   electrodes).

Screen('Preference','SkipSyncTests',1);              %Suppress sync error messages
Screen('Preference','VisualDebugLevel', 0);

eeg = false;                        %Turn on to work with EEG equipment
whichEEG = 'biosemi';                                % 'egi' or 'biosemi'
screenNumber = max(Screen('Screens'));
background = [128 128 128];
window = Screen('OpenWindow',screenNumber,background);       %Open a blank grey screen
Screen('TextSize', window, 100);

%Create stimulus set
oddSymbol = 'X';
commonSymbol = 'O';
currentSymbol = [];
trials = 80; %10;                                        %Change as needed
odd = 0.2;                                          %20 percent will be odd
nOdd = odd * trials;
nCommon = trials - nOdd;
stimuli = [ones(1,nCommon) ones(1,nOdd)*2];         %Generate sorted list of stimuli, 1 = common, 2 = odd
stimuli = stimuli(randperm(length(stimuli)));       %Randomize order of stimuli

%Initialize EEG
if eeg
    if strcmp(whichEEG,'egi')
        TTL_pulse_dur = 0.05;
        trigDevice = Initialize_EEG();
    elseif strcmp(whichEEG,'biosemi')
        s = daq.createSession('ni');           %Initialize DAQ for Biosemi
        channel = addDigitalChannel(s,'Dev1','Port1/Line0:7','OutputOnly');
    else
        disp('Unknown EEG system requested. Quitting now')
        close all
        clear all
        Screen('CloseAll')
        return
    end
end

%Run the experiment, replace with your code
for i = 1:trials
    
    if stimuli(i) == 1                          %Switch to current symbol
        currentSymbol = commonSymbol;
    elseif stimuli(i) == 2
        currentSymbol = oddSymbol;
    end
    
    %Draw stimulus
    DrawFormattedText(window, currentSymbol, 'center','center',[0 0 0]);
    Screen('Flip',window);
    
    %Send trigger when stimulus is presented, common = trigger 1, odd = trigger 2
    if eeg
        if strcmp(whichEEG,'egi')
            DaqDOut(trigDevice,0,stimuli(i));
            WaitSecs(TTL_pulse_dur);
            DaqDOut(trigDevice,0,0);                %Stop sending trigger
        elseif strcmp(whichEEG,'biosemi')
            outputSingleScan(s,dec2binvec(stimuli(i),8));    %Needs to be 8-digit binary
            outputSingleScan(s,[0 0 0 0 0 0 0 0]);  %Stop sending trigger
        end
    end
    WaitSecs(1);
    
    %Blank ISI
    Screen('Flip',window);
    WaitSecs(1);
end

%Close EEG recording
if eeg
    if strcmp(whichEEG,'egi')
        NetStation('StopRecording');
        NetStation('Disconnect');
    end
    %Biosemi system does not need to be closed aside from closing psychtoolbox
    %   and parallel port, and doing so with EGI can't hurt.
    Screen('CloseAll');
    clear all
    close all
    
end
end

function trigDevice = Initialize_EEG()
%Establish a connection with Net Station for EGI systems, set up triggering
NS_host = '192.168.1.1';     %IP address for EEG computer
NS_port = 55513;
%Default port
%NS_synclimit = 0.9; % the maximum allowed difference in milliseconds between PTB and NetStation computer clocks (.m default is 2.5)
disp('Init')
%Detect and initialize the DAQ for ttl pulses
d=PsychHID('Devices');
numDevices=length(d);
trigDevice=[];
dev=1;
while isempty(trigDevice)
    if d(dev).vendorID==2523 && d(dev).productID==130 %if this is the first trigger device
        trigDevice=dev;
        %if you DO have the USB to the TTL pulse trigger attached
        disp('Found the trigger.');
    elseif dev==numDevices
        %if you do NOT have the USB to the TTL pulse trigger attached
        disp('Warning: trigger not found.');
        disp('Check out the USB devices by typing d=PsychHID(''Devices'').');
        break;
    end
    dev=dev+1;
end
%NOTE: The DAQ counts as 4 devices. The correct one to use is labeled 0 by
%   the DAQ, or likely the highest number of the 4 using PsychHID (other
%   non-DAQ devices, e.g. mouse/keyboard may be higher or lower in the list.

%trigDevice=4; %if this doesn't work, try 4
%Set port B to output, then make sure it's off
DaqDConfigPort(trigDevice,0,0);
DaqDOut(trigDevice,0,0);
TTL_pulse_dur = 0.005; % duration of TTL pulse to account for hardware lag

% Connect to the recording computer and start recording
NetStation('Connect', NS_host, NS_port)
NetStation('StartRecording');
end