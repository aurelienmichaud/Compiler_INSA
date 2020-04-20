void main() {
	{
		int a = (2 + 1) * 3;
		int b = a + 12;
		int *p = &a;
		int **x = &p;
		int ***y = &x;

		{
			int c = 12;
			int a = 3;
			c = a + *x;
			printf(c);
		}

		**x = 32;
		***y = 33;

		int g;
		g = 37;
		printf(a);
		int d = 10 + *(*(*y));

		b = 3;

		if (a == 3) {

			printf(a);
		} else {
			if(a - 2) {
			} else {
				while (1) {
					while(b == 3) {
						printf(b);
					}
					printf(2);
				}
			}
		}
	}
	int z = 0;

	printf(z);
}
