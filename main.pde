import themidibus.*;

MidiBus nano,pc;
boolean a,notes,cycle;
int chan,prenum;
int[][] cca= new int[128][18];   //16 canales, "contador", nota asociada
String[][] buttonType= new String[16][128];
String[] auxArray;

void setup(){

  size(300,300);
  background(300);
  smooth();
  nano=new MidiBus(this,"nanoKONTROL2","nanoKONTROL2");
  pc=new MidiBus(this,"nanoKONTROL2", "loopMIDI Port");

  setl(0);
  notes=false;
  a=false;
  cycle=false;
  chan=0;
  prenum=48;

  for (int i=0;i<=127;i++){
    for (int j=0;j<=16;j++){
      cca[i][j]=0;
    }
  }
 for (int i=64;i<=67;i++)   cca[i][17]=i-28;
 for (int i=48;i<=51;i++)   cca[i][17]=i-8;   
 for (int i=32;i<=35;i++)   cca[i][17]=i+12;
 
 for (int i=68;i<=71;i++)   cca[i][17]=i-20;
 for (int i=52;i<=55;i++)   cca[i][17]=i;   
 for (int i=36;i<=39;i++)   cca[i][17]=i+20;
String[] buttons = loadStrings("buttons.txt");


for (int i=0;i<=15;i++){
   auxArray = (split(buttons[i*6+2],','));    
   for(int j=32;j<=39;j++){      
     buttonType[i][j]=auxArray[j-32];
   }
   auxArray = (split(buttons[i*6+3],','));
   for(int j=48;j<=55;j++){
     buttonType[i][j]=auxArray[j-48];
   }  
   auxArray = (split(buttons[i*6+4],','));
   for(int j=64;j<=71;j++){
     buttonType[i][j]=auxArray[j-64];
   }   

 }
 

}

void controllerChange(int channel, int number, int value) {
  
  
  ///// MIS MAPEOS
  if ( (number>=60)&&(number<=62) ){          //scroll thru Live   ------- condicion anterior:  if ( (number>=60)&&(number<=62)&&(chan==14) ){    
    int newnote=0;
    if (number==60) newnote=125;
    if (number==61) newnote=126;
    if (number==62) newnote=127;
    
    if ( (cca[number][16])==0 ){
        pc.sendNoteOn(14,newnote,100);
        cca[number][16]=cca[number][16]+1;      
      }
      else if  (cca[number][16]==3){
        cca[number][16]=0;
        pc.sendNoteOff(channel,newnote,100);
      }
      else   cca[number][16]++;   
      
  }
       
    
  ////
  
  
  if ( (number<=7)||( (number>=16)&&(number<=23)) ) {
    if (!cycle)cc(number,value);
    if (cycle)cc(number+8,value);
  }
    

  if ((number==46)&&!a){
      if ( (cca[number][16])==0 ){
      if (cycle) nano.sendControllerChange(0,46,0);
      else nano.sendControllerChange(0,46,127);
      cycle=!cycle;
      cca[number][16]++; 
  }
  
  else if  (cca[number][16]==3){
    cca[number][16]=0;
  }
   else   cca[number][16]++;  
 } 
 
 
  
  if ((number==59)&&!a){
      if ( (cca[number][16])==0 ){
      notes=!notes;
      cca[number][16]++; 
  }
  
  else if  (cca[number][16]==3){
    cca[number][16]=0;
  }
   else   cca[number][16]++;  
 }
 
  if ( (number>=41)&&(number<46)||(number>=60)&&(number<=62)) {
    if ( (number>=60)&&(number<=62)&&(chan==14) ){}                         //esta línea de codigo se hizo para salvar mi mapeo custom
    else    cc(number,value);
  }
    
  
  if (!notes){         //si se está en el modo cc

  if ( ( (number>=32)&&(number<=39)||(number>=48)&&(number<=55)||(number>=64)&&(number<=71) ) &&(!a) ) { 
    if (buttonType[chan][number].equals("t")) m2t(number); else cc(number,value); 
  }

  
  if ((a)&&( (number>=64)&&(number<=71)||(number>=48)&&(number<=55) ))    {           
   int phi=0;
   if ( (number>=48)&&(number<=55) ) phi=48; else if( (number>=64)&&(number<=71) ) phi=56;
   if ( (cca[number][16])==0 ){

     
    pc.sendNoteOn(15,cca[prenum][17],100) ;      //CUSTOM, un canal a la vez
     
    chan=number-phi; 
    cc2note(15,number,value);   //MAPEO CUSTOM para seleccionar pista y canal simultaneamente
    cycle=false;
    setl(chan);   
    //cca[number][16]=cca[number][16]+1;    linea comentada para que mapeo custom funcione
    
    prenum=number;
  }
  else if  (cca[number][16]==3){   cca[number][16]=0;  a=false; pc.sendNoteOff(15,cca[prenum][17],100) ;  }    //CUSTOM: ultima sentencia para tener un solo canal a la vez
  else   cca[number][16]++; 
  
  }




        
    
  
  }else{
    if ( ( (number>=32)&&(number<=39)||(number>=48)&&(number<=55)||(number>=64)&&(number<=71) ) )   cc2note(chan,number,value);
    }   

  if (number==58) {   
   for (int i=32;i<=39;i++)nano.sendControllerChange(0,i,0);  
   for (int i=48;i<=55;i++)nano.sendControllerChange(0,i,127);   
   for (int i=64;i<=71;i++)nano.sendControllerChange(0,i,127); 
   notes=false;
   a=true;
  }


}



  
void draw(){    
}

void stop() {

  for (int i=0; i<=127; i++){
    nano.sendControllerChange(0,i,0);
  }
      super.stop();
} 