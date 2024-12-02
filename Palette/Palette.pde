/*
 * Palette Graphique - prélude au projet multimodal 3A SRI
 * 4 objets gérés : cercle, rectangle(carré), losange et triangle
 * (c) 05/11/2019
 * Dernière révision : 28/04/2020
 */
 
import java.awt.Point;
import fr.dgac.ivy.*;

Ivy bus;


ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;

String message= "";


void setup() {
  size(800,600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  surface.setLocation(20,20);
  sketch_icon = loadImage("Palette.jpg");
  surface.setIcon(sketch_icon);

  try
  {
    bus = new Ivy("Palette", " sender_processing is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("^ordre=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = args[0];
        ordre(message);
        try
        {
          bus.sendMsg("Demo_Processing Feedback=ok");
        }
        catch (IvyException ie) {}  
           
      }        
    });
    bus.bindMsg("^lieu=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = args[0];
        println(message);
        try
        {
          bus.sendMsg("Demo_Processing Feedback=ok");
        }
        catch (IvyException ie) {}  
           
      }        
    });
    
  }
  catch (IvyException ie)
  {
  }
  
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;
}


void draw() {
  background(0);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/l(osange)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("m(ove)+ click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      text("click sur un objet pour changer sa couleur de manière aléatoire", 50,110);
      break;
      
    case AFFICHER_FORMES:  // 
    case DEPLACER_FORMES_SELECTION: 
    case DEPLACER_FORMES_DESTINATION: 
      affiche();
      break;   
      
    default:
      break;
  }  
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void mousePressed() { // sur l'événement clic

  Point p = new Point(mouseX,mouseY);
  try
  {
    bus.sendMsg("lieu " + p.toString());
  }
  catch (IvyException ie)
  {
  }
  
  switch (mae) {
      
   case DEPLACER_FORMES_SELECTION:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.DEPLACER_FORMES_DESTINATION;
        }         
     }
     if (indice_forme == -1)
       mae= FSM.AFFICHER_FORMES;
     break;
     
   case DEPLACER_FORMES_DESTINATION:
     if (indice_forme !=-1)
       (formes.get(indice_forme)).setLocation(new Point(mouseX,mouseY));
     indice_forme=-1;
     mae=FSM.AFFICHER_FORMES;
     break;
     
    default:
      break;
  }
}

void ordre(String ordre) {
  
  String[] tmp = split(ordre,":");
  println(tmp);
  println(tmp[0]);
  if (tmp[0].equals("cree")){
    print("ufhbvhsbdibsdlivbsdivbsdivubldfvblsdu");
    String forme = tmp[1];
    String couleur = tmp[2];
    int x = int(tmp[3]);
    int y = int(tmp[4]);
    color c = color(0,0,0);
    switch(couleur) {
      case "rouge":
        c = color(255,0,0); 
        break;
      case "vert":
        c = color(0,255,0); 
        break;
      case "bleu":
        c = color(0,0,255); 
        println("hfbdvb");
        break;
      case "noir":
        c = color(0,0,0); 
        break;
  }
  
  println(forme,x,y);
  Point p = new Point(x,y);
  println("ivi");
  switch(forme) {
    case "rectangle":
      Forme f= new Rectangle(p);
      formes.add(f);
      f.setColor(c);
      mae=FSM.AFFICHER_FORMES;
      break;
      
    case "cercle":
      Forme f2=new Cercle(p);
      formes.add(f2);
      f2.setColor(c);
      mae=FSM.AFFICHER_FORMES;
      break;
    
    case "triangle":
      Forme f3=new Triangle(p);
      formes.add(f3);
      f3.setColor(c);
      mae=FSM.AFFICHER_FORMES;
      break;  
      
    case "losange":
      Forme f4=new Losange(p);
      formes.add(f4);
      f4.setColor(c);
      mae=FSM.AFFICHER_FORMES;
      break;    
 }
  }
  if (tmp[0].equals("deplacer")){
    int indice_forme = -1;
      int x1 = int(tmp[1]);
      int y1 = int(tmp[2]);
      int x2 = int(tmp[3]);
      int y2 = int(tmp[4]);
    Point p1 = new Point(x1,y1);
    Point p2 = new Point(x2,y2);
    for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p1)) {
          indice_forme = i;
        
  }
    }
  if (indice_forme !=-1){
       (formes.get(indice_forme)).setLocation(p2);
     indice_forme=-1;
    
}
    }
    
    
    if (tmp[0].equals("supprimer")){
      int x1 = int(tmp[1]);
      int y1 = int(tmp[2]);

    Point p1 = new Point(x1,y1);
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p1)) {
          formes.remove(i);
        
  }

    }}
  }
