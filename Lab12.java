package 
public class Lab12 {
  public static void main(String[] args){
    int sum;
    for(int i=1;i<=100;i++){
      sum = 0;
      for(int j=1;j<=i;j++){
        if(i%j==0) sum++;
      }
      if(sum == 2) System.out.println(i);
    }
 }
}
