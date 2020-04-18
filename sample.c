void main() {
	int a = 123 + 13;
	int b = a + 12;

	{
		int c = 12;
		int a = 3;
		c = a;
		printf(c);
	}

	printf(a);
	int d = 10;

	b = 3;

	if (a < 3) {

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

	printf(d);
}
