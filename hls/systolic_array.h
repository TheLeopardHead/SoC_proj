#ifndef SYSTOLIC_ARRAY_H
#define SYSTOLIC_ARRAY_H

#include <ap_int.h>

typedef float DataType;

#define SIDE_LEN		36								// The length of a side of the systolic array
//#define ARRAY_SIZE		(SIDE_LEN*SIDE_LEN)

void systolic_array(ap_uint<16> row, ap_uint<16> col, ap_uint<16> col1, DataType din_a[], DataType din_b[], DataType bias[], DataType out[]);

#endif
