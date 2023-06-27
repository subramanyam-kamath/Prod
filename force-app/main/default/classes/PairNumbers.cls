public class PairNumbers {
    integer  x,y;

    public PairNumbers(integer a, integer b) {
        x=a;
        y=b;
        
        createAccount();        
         
    }

     public Boolean equals(Object obj) {
        if (obj instanceof PairNumbers) {
            PairNumbers p = (PairNumbers)obj;
             return ((x==p.x) && (y==p.y));
             
            
             
        }
        
        
        
        return false;
    } 

    public Integer hashCode() {
        return (31 * x) ^ y;
        
        
    } 
    
    
    
   public integer createAccount(){
   
   return  x;
  
       
        }
}