################
#### Header ####
################
scenario = "Son_calibration";
active_buttons = 3;
button_codes = 1, 2, 3;
default_font = "Calibri";

$delai_son = 200;
$rond_dur = 2000;
$cross_dur = 1500;
$trial_dur = '$rond_dur + $cross_dur';

##################
#### SDL Part ####
##################
begin;

# Consignes
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 3;
	picture {
		text { caption = "Réglages"; font_size = 48; font_color = 255, 255, 0; }; x = 0; y = 250;
		text { caption = "Clique à chaque fois que tu entends le chien aboyer."; font_size = 24; }; x = 0; y = 0;
		#text { caption = "Appuie sur la barre d'espace pour démarrer."; font_size = 18; font_color = 255, 100, 0;}; x = 0; y = -225;
	};
} instructions;

trial {					 
   trial_duration=2000;
   nothing{}; 
	} trial_no;
	
trial {
   trial_duration = 2000;
   picture {
      text {
         caption = " "; font_size = 36; font_color = 255, 255, 0; 
         system_memory = true;
      } newtestText_ttb;
      x = 0; y = 0;
   };
} newtest_ttb;
        

# Presentation du stimulus sonore + indice visuel puis croix de fixation

wavefile { filename = "tarson.wav"; } ba;
bitmap { filename = "orange_circle.bmp"; } hp;
picture {
	box {
		color = 255, 255, 255;
		height = 50; width = 5;
	};
	x = 0; y = 0;
	box {
		color = 255, 255, 255;
		height = 5; width = 50;
	};
	x = 0; y = 0;
} pic_cross;


trial { 
	trial_duration = $trial_dur;
	trial_type = fixed;
	terminator_button = 1,2;
	picture { 
		bitmap hp;
		x = 0; y = 0;	
	};
	duration=$rond_dur;
	sound { wavefile ba;} stim;
	time = $delai_son;
	picture pic_cross;
	time = $rond_dur;	
} play_ans;



# Presentation d'un ecran annocant la fin de la calibration
trial {
	trial_duration = 2000;
	picture {
		text { caption = "Réglages terminés !"; font_size = 36;};
		x = 0; y = 0;
	};
} end_screen;


##################
#### PCL Part ####
##################
begin_pcl;

# Definition des variables
int Seq_tot=2;
array <int> speakerCodes[2] = {1, 2}; # 1 = Left, 2 = Right, 3 = Both 
int SPEAKERCODE_CNT = speakerCodes.count(); # total speaker configs to test
array <double> speakerPans[SPEAKERCODE_CNT] = {-1.0, 1.0};
array <string> speakerStrings[SPEAKERCODE_CNT] = {"gauche", "droite"};
string newtestTextString1;
string newtestTextString2;
string termString1;
string termString2;

# create random test order for tests 1 => Seq_tot
array <int> testNumber[Seq_tot];
array <string> testSpeaker[Seq_tot];
array <int> testSpeakerCode[Seq_tot];
array <double> testPan[Seq_tot];
int nTest = 1;
loop  int nSpeakerCode = 1 until nSpeakerCode > SPEAKERCODE_CNT
	begin
   testNumber[nTest] = nTest;
   testSpeaker[nTest] = speakerStrings[nSpeakerCode];
   testSpeakerCode[nTest] = speakerCodes[nSpeakerCode];
   testPan[nTest] = speakerPans[nSpeakerCode];
   nTest = nTest + 1;
   nSpeakerCode = nSpeakerCode + 1;
end;
testNumber.shuffle();

# Presentation des consignes
instructions.present();
trial_no.present();

# Ouverture du fichier .txt de sortie
output_file ofile1 = new output_file;
ofile1.open( logfile.subject() + "_thresholds.txt" );
ofile1.print("SOUND\t  SPKR_CD\tVOLUME\tATTENUATION\n");

# create string for later output to terminal window
termString1 = "SOUND\tSPKRCD\tVOLUME\tATTENUATION\n";
term.print("Test Results:\n");
term.print(termString1);

# boucle pour chaque oreille
loop int nSeq = 1 until nSeq > Seq_tot
begin
double att = 0.2;
double vol =0.0;
double pas = 0.5;
double dir = 1.0;	
string curSpeaker;
int curSpeakerCode;
double curPan;
	
# set parameters for new test
output_file ofile2 = new output_file;
#ofile2.open( "debug" + string(nSeq) + ".txt" );
#ofile2.print(string(testNumber[nSeq]));
#ofile2.close();
curSpeaker = testSpeaker[testNumber[nSeq]];
curSpeakerCode = testSpeakerCode[testNumber[nSeq]];
curPan = testPan[testNumber[nSeq]];
stim.set_attenuation(att);
stim.set_pan(curPan);

# alert subject to start of next test
newtestTextString1 = "Test " + string(nSeq) + " sur " + string(Seq_tot) + "...";
newtestTextString2 = " \n" + "Oreille " + curSpeaker ;
newtestText_ttb.set_caption(newtestTextString1 + "\n" + newtestTextString2);
newtestText_ttb.redraw();
newtest_ttb.present();	
	
# Calcul de l'attenuation necessaire pour atteindre 0dB SL
loop until
	pas < 1.0/256.0
	begin
	play_ans.present();
	if response_manager.response_count() == 1
		then 
			if dir == -1.0
				then pas = 0.5 * pas;
			end;
			dir = 1.0;
		else
			if dir == 1.0
				then pas = 0.5 * pas; 
		   end;
		   dir = -1.0;
	end;
att = att + dir * pas;
if att > 1.0 then att = 1.0; end;
if att < 0.0 then att = 0.0; end;
stim.set_attenuation(att);
end;


# Calcul du volume
vol =  1.0 - att ;

# Ecriture de cette valeur dans un .txt
ofile1.print("tarson.wav" + "\t" + string(curSpeakerCode) + "\t" + string(vol) + "\t"  + string(att) + "\n");   
nSeq = nSeq+1;

termString2 = "tarson.wav"  + "\t" + curSpeaker + "\t"  + "  " + string(vol) + "\t" + string(att) + "\n";
term.print(termString2);
#parameter_window.set_parameter(parDispWin[testNumber[nTest]],string(att));

end;

end_screen.present();
ofile1.close();
