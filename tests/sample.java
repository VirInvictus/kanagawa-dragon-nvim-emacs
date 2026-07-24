// sample.java — visual eyeball buffer for kanagawa-dragon-nvim.
// Open this file with `M-x java-ts-mode' (or rely on file-local
// auto-mode) and `(setq treesit-font-lock-level 4)' to reproduce the
// high-granularity highlighting the screenshot was taken from.

public class Rectangle {
    int width;
    int height;

    Rectangle() {
        this.width = 1;
        this.height = 1;
    }

    Rectangle(int width, int height) {
        this.width = width;
        this.height = height;
    }

    void calculateArea() {
        System.out.println(width + "x" + height + " = " + width * height);
    }

    void setWidth(int width) {
        this.width = width;
    }

    void setHeight(int height) {
        this.height = height;
    }

    public static void main(String[] args) {
        Rectangle rec1 = new Rectangle();
        Rectangle rec2 = new Rectangle(15, 7);

        System.out.println("Rectangle 1:");
        rec1.calculateArea();
        System.out.println("Rectangle 2:");
        rec2.calculateArea();

        rec2.setHeight(23);
        rec2.calculateArea();
    }
}
