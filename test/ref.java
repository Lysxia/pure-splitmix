import java.util.SplittableRandom;

class Main {
  public static void main(String[] args) {
    SplittableRandom g0 = new SplittableRandom(33);
    System.out.println(g0.nextLong());
    System.out.println(g0.nextLong());
    SplittableRandom g1 = g0.split();
    System.out.println(g1.nextLong());
    SplittableRandom g2 = g1.split();
    System.out.println(g1.nextLong());
    SplittableRandom g3 = g2.split();
    System.out.println(g2.nextLong());
    System.out.println(g2.nextLong());
    System.out.println(g3.nextLong());
    System.out.println(g3.nextLong());
    System.out.println(g3.nextLong());
    for (int i = 0; i < 300; i++) {
      g3 = g3.split();
    }
    System.out.println(g3.nextLong());
  }
}
