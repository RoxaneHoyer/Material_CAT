# =================================   Header   =====================================
#dur_cue ds les trials fixés a 192..a initialiser peut etre par pcl si amene a changer
#
scenario = "22_novembre_2011";

write_codes = true; 		# to send codes to recording system 
pulse_width = 5;    		# width of pulses sent to recording system
response_port_output=true;
default_output_port = 1; 
response_matching=simple_matching;
no_logfile= false;
active_buttons=3;		#bouton poussoir
button_codes=251,252,253;

#===parametres ecran========
default_font_size = 40 ;
default_font = "Arial";
default_text_color = 0, 0, 0;   #noir
screen_width = 1024;
screen_height = 768;
screen_bit_depth = 32;
default_background_color = 200, 200, 200;

begin;
TEMPLATE "PrepAtt_stim_trial_timing.tem" {}; 

begin_pcl;
preset string nom_sujet;
preset string num_bloc;

# ==========   Definition des parametres temps   ===================================
int duree_instruc_task=2000;	#affichage de la tache 2s 
int duree_instruc=1000; 		#instruction 1s avant debut des sons
int max_rep=2300;
int rep_plus=0;
int delay_plus1=0;
int delay_plus2=0;

# ===========   Definition des parametres son   ====================================
int dur_sTAR=50;			#target sound duration
int dur_sDIS=300;
int dur_cue=200;			#cue presentation 192 (a verifier dans TEMPLATE "PrepAtt_stim_trial.tem") pour 200 dans les trials = 12 trames a 60Hz
double correc_atttar =-0.35;
double correc_attdis =-0.35;
array<double> final_att[2];# valeurs de l'attenuation g et d specific à chaque sujet
array<int>side[2];#tableau des cotés 1=gauche, 2=droite 
double final_attg;#valeur de l'atténuation g renvoyée par le fichier "threshold"
double final_attd;#valeur de l'atténuation d renvoyée par le fichier "threshold" 
double att_sTARg;#target sound attenuation appliquée à gauche à la carte son après correction éventuelle
double att_sTARd;#target sound attenuation appliquée à droite à la carte son après correction éventuelle
double att_sDISg;#distracter sound attenuation left
double att_sDISd;#distracter sound attenuation right

#===déclaration des variables
string filename;
int nbessais = 0;
int num;
int trialt;
string cue;
int codCUE;
int delay1;
int dis;
int dis1;
int tar;
int codDIS;
string DIS;
int delay2;
string TAR;
int codTAR;
int bp;
int ISIrand;
int nbrep;
string temp;
array<int> meantr[0];
double moytr;
int valide;
int rep=0;
int rec_time;
int fa=0;
int missrep=0;
int multirep=0;
int rep_before_tar=0;
int cuefic;
int t=0;

#============lecture des attenuations dans fichier=================
input_file inatt = new input_file;
filename.append("C:/users/Aurelie/PAT/PrepAtt_EEG/PrepAtt_EEG19/log/");
filename.append(nom_sujet);
filename.append("_thresholds");
filename.append(".txt");
inatt.open(filename,false);
inatt.get_line(); # saute la 1ere ligne
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[1]=inatt.get_int();#read side 1
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();#read volume
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[1]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[2]=inatt.get_int();#read side 2
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();#read volume
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[2]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.close();
if(side[1]==1) then
  final_attg=final_att[1];
  final_attd=final_att[2];
else
  final_attg=final_att[2];
  final_attd=final_att[1];
end;

#============calcul des attenuations========================
att_sTARg=final_attg+correc_atttar;
att_sTARd=final_attd+correc_atttar;
att_sDISg=final_attg+correc_attdis;
att_sDISd=final_attd+correc_attdis;

#==================affichage des attenuations================
text1.set_caption("left attenuation: "+string(final_attg)+"  right attenuation: "+string( final_attd)+"\n Press Enter to continue"); 
text1.redraw();
info_trial.present();

#=============affichage instructions==========================
trial_instruc.set_duration(duree_instruc_task);
trial_instruc.present();
trial_no.set_duration(duree_instruc);
trial_no.present();

#===Premiere lecture fichier parametres pour trouver le nombre de lignes
input_file in = new input_file;
filename="";
filename=("PrepAtt_tr_aud_3d_rand"+num_bloc+".txt");
in.open(filename);
loop until
   in.end_of_file()
begin 
  	in.get_line();
	if in.last_succeeded()
	then
		nbessais = nbessais+1;
	else
		break;
	end;
end;
in.close();

#============creation fichier resultat=====================
filename="";
filename.append(nom_sujet);
filename.append("_");
filename.append(num_bloc);
filename.append("_pat.txt");
output_file out = new output_file;
out.open(filename,false ); 
out.print("codage resultats");
out.print("\n");
out.print("nom sujet");
out.print("\n");
out.print("numero bloc");
out.print("\n");
out.print("numero essai;cue;delay1;dis;delay2;tar;reponse attendue;reponse sujet;fa;multirep;temps de reaction");
out.print("\n");
out.print("cue 1=gauche 2=droite 0=bilaterale");
out.print("\n");
out.print("dis 0=pas de distracteur 1=dis position1 2=dis position2 3=dis position3");
out.print("\n");
out.print("tar 1=gauche 2=droite");
out.print("\n");
out.print("missrep = pas d'appui apres la cible");
out.print("\n");
out.print("fausses alarmes fa = appui avant la cible");
out.print("\n");
out.print("multirep = plusieurs reponses apres la cible");
out.print("\n");
out.print("moy tr = moyenne temps reaction");
out.print("\n");
out.print("\n");
out.print(nom_sujet);
out.print("\n");
out.print(num_bloc);
out.print("\n");

#====Deuxieme lecture fichier parametres pour initialiser variables de la boucle
#de presentation des trials
filename="";
filename=("PrepAtt_tr_aud_3d_rand"+num_bloc+".txt");
in.open(filename);
in.get_line(); # saute la 1ere ligne
int i=1;
#debut de la boucle
loop until 
   in.end_of_file() || !in.last_succeeded() || (i > nbessais+1)
begin
t=t+1;
   in.set_delimiter('\n');
	num=in.get_int();
   if !in.last_succeeded() then break; end;
   valide=in.get_int();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   cue=in.get_line();
   cue=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   codCUE=in.get_int();
	if !in.last_succeeded() then break; end;
	delay1=in.get_int();
	if !in.last_succeeded() then break; end;
	dis1=in.get_int();
 	if !in.last_succeeded() then break; end;
 	codDIS=in.get_int();
 	if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   DIS=in.get_line();
   DIS=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   delay2=in.get_int();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   TAR=in.get_line();
   TAR=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   codTAR=in.get_int();
   if !in.last_succeeded() then break; end;
   bp=in.get_int();
   if !in.last_succeeded() then break; end;
   ISIrand=in.get_int();
   if !in.last_succeeded() then break; end;
   in.get_line(); # saute la fin de ligne
   
   codCUE=20;  #a supprimer
   codTAR=t;
#====attribution des noms d'événements et trials
   TAR=TAR+(".wav");
   if dis1==0 then
		dis=1;
	else
		dis=2;
	end;
   DIS=DIS+(".wav");
   Sound_dis_wav.set_filename(DIS);
   Sound_tar_wav.set_filename(TAR);
 
	#cue + dis
   if (cue=="Larrow") then
     event_cue.set_stimulus(Larrow);
     event_cue_dis.set_stimulus(Larrow);
     cuefic=1;
     end;
   if (cue=="Rarrow") then
     event_cue.set_stimulus(Rarrow);
     event_cue_dis.set_stimulus(Rarrow);
     cuefic=2;
   end;
   if (cue=="Barrow") then
     event_cue.set_stimulus(Barrow);
     event_cue_dis.set_stimulus(Barrow);
     cuefic=0;
   end;
   if (DIS!="nul.wav") then
     Sound_dis.get_wavefile().load();
     event_cue_dis.set_event_code(string(codCUE));
     event_cue_dis.set_port_code(codCUE);
     event_dis.set_event_code(string(codDIS));
     event_dis.set_port_code(codDIS);
     if(final_attd>=final_attg) then
       Sound_dis.set_pan(-att_sDISd+att_sDISg);
       Sound_dis.set_attenuation(att_sDISg);
     else
       Sound_dis.set_pan(att_sDISd-att_sDISg);
       Sound_dis.set_attenuation(att_sDISd);
     end;
   else
     event_cue.set_event_code(string(codCUE));
     event_cue.set_port_code(codCUE);
   end;  
   trial_cue.set_duration(dur_cue+delay1+delay_plus1+dur_sDIS+delay2+delay_plus2);
   trial_cuedis.set_duration(dur_cue+delay1+delay_plus1+dur_sDIS+delay2+delay_plus2);
   event_dis.set_delta_time(dur_cue+delay1+delay_plus1);
   nbrep=0;
   rep=0;
   rep_before_tar=0;
   
   random_trial[dis].present();
   
	if (bool( response_manager.response_count() )) then
	  fa=fa+1;
	  rep_before_tar=response_manager.response_count();;
	  rec_time=0;
	end;
	
	#target
	if (TAR=="S_tarson_L.wav") then
     Sound_tar.set_pan(-1.0);#attenuation a droite maxi
     Sound_tar.set_attenuation(att_sTARg);#attenuation a gauche de "att_sTARg"
     tar=1;
   else
     Sound_tar.set_pan(1.0);#attenuation a gauche maxi
     Sound_tar.set_attenuation(att_sTARd);#attenuation a droite de "att_sTARd"
     tar=2;
   end;
   trial_tar.set_duration(dur_sTAR+max_rep+rep_plus+ISIrand);
   event_target.set_target_button(bp);#determine la reponse attendue 	
   event_target.set_event_code(string(codTAR));
   event_target.set_port_code(codTAR);
	
	trial_tar.present();
	
	if (bool( response_manager.response_count() )) then
     response_data last = response_manager.last_response_data();
     rep=last.button();
     stimulus_data last1 = stimulus_manager.last_stimulus_data();
     rec_time=last1.reaction_time();
     nbrep=response_manager.response_count(); 
   else
   missrep=missrep+1;
     rec_time=0;  
   end;  
   if (nbrep>0) then
     if(nbrep)>1 then
       multirep=multirep+1;
       meantr.add(rec_time);
       #rec_time=0;
     else  
       meantr.add(rec_time);
     end;  
  end; 
  
  #ecriture trial
     out.print(i);
     out.print(";");
     out.print(cuefic);
     out.print(";");
     out.print(delay1);
     out.print(";");    
     out.print(dis1);
     out.print(";");
     out.print(delay2);
     out.print(";");  
     out.print(tar);
     out.print(";");
     out.print(bp);
     out.print(";");
     out.print(rep);
     out.print(";");
     out.print(rep_before_tar);
     out.print(";");
     out.print(nbrep);
     out.print(";");
     out.print(rec_time);
     out.print("\n");
  if(DIS!="nul.wav") then
    Sound_dis.get_wavefile().unload();
  end;
  i=i+1;
end;

#ecriture resultat block
out.print("\n");
out.print("nb trial with no rep:");
out.print(missrep);
out.print("\n");
out.print("nb trial with fa:");
out.print(fa);
out.print("\n");
out.print("nb trial with multirep:");
out.print(multirep);
out.print("\n");
out.print("moy tr:");
moytr=arithmetic_mean(meantr);
out.print(moytr);
out.print("\n");
out.close();
in.close();

#==================affichage moyenne================
text1.set_caption("temps de reaction "+string(moytr)+"\n Press Enter to continue"); 
text1.redraw();
info_trial.present();