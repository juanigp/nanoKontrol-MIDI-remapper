
void cc(int number, int value){ //remapeo cc
  nano.sendControllerChange(0,number,value);  
  pc.sendControllerChange(chan,number,value);  //ver si es necesario cambiarlop
}

void cc2note(int channel, int number, int value){
//  nano.sendControllerChange(0,number,value);
  
  if ( (cca[number][16])==0 ){
    pc.sendNoteOn(channel,cca[number][17],100);
    cca[number][16]=cca[number][16]+1;      
  }
  else if  (cca[number][16]==3){
    cca[number][16]=0;
    pc.sendNoteOff(channel,cca[number][17],100);
  }
  else   cca[number][16]++;   
   
  
}

void setl(int chan){
  for (int i=0;i<=127;i++){
    nano.sendControllerChange(0,i,cca[i][chan]);
  }
}


void m2t(int number){  
if ( (cca[number][16])==0 ){
  
  if( cca[number ][chan]==0) {
      cc(number,127);
      cca[number][chan]=127;
    } 
     else {
      cca[number][chan]=0;
      cc(number,0);
    }
  cca[number][16]=cca[number][16]+1;    
  }
  else if  (cca[number][16]==3)   cca[number][16]=0;  
  else   cca[number][16]++; 
}