#include "systolic_array.h"
#include <ctime>
#include <cstdlib>
#include <iostream>

using namespace std;

#define FEAT_ROW	32
#define FEAT_COL	32
#define TMPL_COL	32

//#define FEAT_ROW	5
//#define FEAT_COL	5
//#define TMPL_COL	5


#define FEAT_SIZE	(FEAT_ROW*FEAT_COL)
#define TMPL_SIZE	(FEAT_COL*TMPL_COL)
#define RES_SIZE	(FEAT_ROW*TMPL_COL)

DataType feat[FEAT_SIZE], tmpl[TMPL_SIZE], bias[FEAT_ROW], res[RES_SIZE];

void init();
bool compare();

int main()
{
	init();

	systolic_array(FEAT_ROW, FEAT_COL, TMPL_COL, feat, tmpl, bias, res);

	cout << "\n" << (compare() ? "TEST PASSED!" : "TEST FAILED!") << "\n\n";

	return 0;
}

void init()
{
	srand(time(0));

	for (int i = 0; i < FEAT_SIZE; i++)
		feat[i] = (DataType)(rand() % 40) - 20;

	for (int i = 0; i < TMPL_SIZE; i++)
		tmpl[i] = (DataType)(rand() % 20) - 10;

	for (int i = 0; i < FEAT_ROW; i++)
		bias[i] = i;
}

template<typename T>
float relative_err(T ref, T val)
{
	float err = val - ref;

	if (err < 0) err = -err;

	return err / ref;
}

bool compare()
{
	bool correct_flag = true;
	int err_row, err_col;
	float ref[RES_SIZE];

	for (int r1 = 0; r1 < FEAT_ROW; r1++)
		for (int c2 = 0; c2 < TMPL_COL; c2++)
		{
			float tmp = 0;

			for (int r2 = 0; r2 < FEAT_COL; r2++)
				tmp += feat[r1*FEAT_COL + r2] * tmpl[r2*TMPL_COL + c2];

			ref[r1*TMPL_COL + c2] = tmp + bias[r1];

			if (relative_err(ref[r1*TMPL_COL + c2], res[r1*TMPL_COL + c2]) > 0.01)
			{
				if (correct_flag)
				{
					err_row = r1;
					err_col = c2;
				}
				correct_flag = false;
			}
		}

	if (!correct_flag)
	{
		cout << "feat:\n";
		for (int r = 0; r < FEAT_ROW; r++)
		{
			for (int c = 0; c < FEAT_COL; c++)
				cout << feat[r*FEAT_COL + c] << "\t";
			cout << "\n\n";
		}

		cout << "tmpl:\n";
		for (int r = 0; r < FEAT_COL; r++)
		{
			for (int c = 0; c < TMPL_COL; c++)
				cout << tmpl[r*TMPL_COL + c] << "\t";
			cout << "\n\n";
		}

		cout << "Reference:\n";
		for (int r = 0; r < FEAT_ROW; r++)
		{
			for (int c = 0; c < TMPL_COL; c++)
				cout << ref[r*TMPL_COL + c] << "\t";
			cout << "\n\n";
		}

		cout << "\nYours:\n";
		for (int r = 0; r < FEAT_ROW; r++)
		{
			for (int c = 0; c < TMPL_COL; c++)
				cout << res[r*TMPL_COL + c] << "\t";

			cout << "\n";
		}

		cout << "\nError occurs at (" << err_row << ", " << err_col << ").\n";
	}

	return correct_flag;
}
