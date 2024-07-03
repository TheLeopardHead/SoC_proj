import torch
import torch.nn.functional as F
import numpy as np

def extract_bits(hex_value):
    value = int(hex_value, 16)
    mask = 0b00000000111111111111111100000000  # 十六进制为 0xF0
    result = (value & mask) >> 8
    return hex(result)

def relu2gelu(hex_value):
    # 将十六进制字符串转换为整数
    value = int(hex_value, 16)

    # 提取第5位到第7位
    mask_low = 0b11100000 
    index_low = (value & mask_low) >> 5

    mask_high = 0b1111111100000000 
    index_high = (value & mask_high) >> 8   

    """
    Delta Binary is: ['0', 'e', '1a', '22', '27', '2b', '2c', '2b',      '29',     '26', '22', '1e', '1a', '16', '12', 'f',      'c']
    """
    # 使用模式匹配来决定要减去的值
    if index_low == 0x0:
        if index_high == 1:
            decrement = 0x29
        elif index_high == 2:
            decrement = 0xc
        else:
            decrement = 0
    elif index_low == 0x1:
        if index_high == 0:
            decrement = 0xe
        elif index_high == 1:
            decrement = 0x26
        else:
            decrement = 0
    elif index_low == 0x2:
        if index_high == 0:
            decrement = 0x1a
        elif index_high == 1:
            decrement = 0x22
        else:
            decrement = 0
    elif index_low == 0x3:
        if index_high == 0:
            decrement = 0x22
        elif index_high == 1:
            decrement = 0x1e
        else:
            decrement = 0
    elif index_low == 0x4:
        if index_high == 0:
            decrement = 0x27
        elif index_high == 1:
            decrement = 0x1a
        else:
            decrement = 0
    elif index_low == 0x5:
        if index_high == 0:
            decrement = 0x2b
        elif index_high == 1:
            decrement = 0x16
        else:
            decrement = 0
    elif index_low == 0x6:
        if index_high == 0:
            decrement = 0x2c
        elif index_high == 1:
            decrement = 0x12
        else:
            decrement = 0
    elif index_low == 0x7:
        if index_high == 0:
            decrement = 0x2b
        elif index_high == 1:
            decrement = 0xf
        else:
            decrement = 0
    else:
        decrement = 0

    # 计算并返回最终值
    new_value = value - decrement
    return hex(new_value)  # 以十六进制字符串的形式返回

def matrix_multiply(tensor1, tensor2):
    # 检查两个张量的形状是否适合矩阵乘法
    if tensor1.size(1) != tensor2.size(0):
        raise ValueError("The number of columns in the first matrix must be equal to the number of rows in the second matrix.")

    # 进行矩阵乘法
    result = torch.matmul(tensor1, tensor2)
    return result

def hex_matrix_multiply(matrix1, matrix2):
    # 转换矩阵元素从16进制到十进制整数
    dec_matrix1 = np.array([[int(x, 16) for x in row] for row in matrix1], dtype=int)
    dec_matrix2 = np.array([[int(x, 16) for x in row] for row in matrix2], dtype=int)
    
    # 检查矩阵是否可以乘
    if dec_matrix1.shape[1] != dec_matrix2.shape[0]:
        raise ValueError("The number of columns in the first matrix must equal the number of rows in the second matrix.")
    
    # 执行矩阵乘法
    result_matrix = np.dot(dec_matrix1, dec_matrix2)
    
    # （可选）将结果矩阵的元素转换回16进制字符串
    hex_result_matrix = np.vectorize(hex)(result_matrix)
    
    return hex_result_matrix

def calculate_gelu(tensor):
    # 计算GELU激活值
    return F.gelu(tensor)

def float32_to_fixed16(num):
    # 假设 num 是从张量的 item() 方法得到的浮点数
    scaled_num = num * 256.0
    fixed_num = round(scaled_num)  # 使用 Python 的内置 round 函数

    # 转换 fixed_num 为整数
    fixed_num = int(fixed_num)

    # 检查 fixed_num 是否在 16 位整数范围内
    if fixed_num >= 65536 or fixed_num <= -65536:
        raise ValueError("The number after scaling is too large to fit in 16 bits.")
    if fixed_num < -32768 or fixed_num > 32767:
        raise ValueError("The number is out of range for a 16-bit signed integer.")

    # 将整数转换为 16 位二进制字符串
    binary_string = format(fixed_num & 0xFFFF, '016b')
    
    # 将二进制字符串转换为 16 进制字符串
    hex_string = hex(int(binary_string, 2))[2:]  # 使用 [2:] 去掉前缀 '0x'
    
    return hex_string

def fixed16_to_float32(fixed):
    # 检查是否为16位二进制字符串
    if len(fixed) != 16 or not all(c in '01' for c in fixed):
        raise ValueError("Input must be a 16-bit binary string.")

    # 将二进制字符串转换为16位有符号整数
    if fixed[0] == '1':  # 负数处理
        # 计算补码
        fixed_num = -((int(fixed, 2) ^ 0xFFFF) + 1)
    else:
        fixed_num = int(fixed, 2)
    
    # 将定点数转换回浮点数，除以2^8
    return fixed_num / 256.0



if __name__ == "__main__":
    # 创建一个张量
    input_tensor = torch.tensor(
        [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0, 1.125, 1.25, 1.375, 1.5, 1.625, 1.75, 1.875, 2.0,], dtype=torch.float32)
    # deltaa LUT
    """
    Delta Binary is: ['0', 'e', '1a', '22', '27', '2b', '2c', '2b', '29', '26', '22', '1e', '1a', '16', '12', 'f', 'c']
    """

    """
    test optimized GELU
    """
    # 计算并打印GELU激活后的结果
    # output_tensor = calculate_gelu(input_tensor)
    # output_bin = [float32_to_fixed16(num.item()) for num in output_tensor]
    # input_bin = [float32_to_fixed16(num.item()) for num in input_tensor]
    # print("Input Tensor:", input_tensor)
    # print("Input Binary:", input_bin)
    # print("GELU Output Tensor:", output_tensor)
    # # delta = input_tensor- output_tensor
    # # delta_bin = [float32_to_fixed16(num.item()) for num in delta]
    # # print("Delta is:", delta)
    # # print("Delta Binary is:", delta_bin)
    # print("Output Binary is:", output_bin)
    # cal_output = [relu2gelu(hex_value) for hex_value in input_bin]
    # print("Caclated Output Binary is:", cal_output)





    # 创建两个4x4的张量
    tensor1 = torch.tensor([
        [0.3519, 0.8000, 0.8494, 0.7135, 0.0591, 0.6980, 0.5005, 0.6035],
        [0.1805, 0.8170, 0.4250, 0.9319, 0.3604, 0.5969, 0.2089, 0.1362],
        [0.2536, 0.1360, 0.4226, 0.1068, 0.3897, 0.5425, 0.6061, 0.7492],
        [0.3841, 0.0789, 0.8986, 0.2316, 0.4563, 0.6261, 0.3557, 0.5117]
    ], dtype=torch.float32)
    tensor2 = torch.tensor([
        [0.6291, 0.3504, 0.4789, 0.8167],
        [0.1927, 0.4207, 0.1271, 0.7167],
        [0.7123, 0.0201, 0.5102, 0.3372],
        [0.0371, 0.4545, 0.3779, 0.1653],
        [0.6221, 0.8838, 0.4663, 0.2016],
        [0.5069, 0.3257, 0.6726, 0.5322],
        [0.1016, 0.1773, 0.8077, 0.5729],
        [0.4086, 0.8450, 0.8129, 0.4301]
    ], dtype=torch.float32)
    """
    Result of Matrix Multiplication:
    tensor([[1.6951, 1.6795, 2.3651, 2.1949],
            [1.2119, 1.5039, 1.6081, 1.5988],
            [1.3758, 1.4647, 2.0399, 1.5015],
            [1.7519, 1.3937, 2.0771, 1.5606]])
    """

    # 调用函数进行矩阵乘法
    result = matrix_multiply(tensor1, tensor2)
    tensor1_bin = [float32_to_fixed16(num.item()) for row in tensor1 for num in row]
    tensor2_bin = [float32_to_fixed16(num.item()) for row in tensor2 for num in row]
    # 将列表重组为4x8矩阵
    matrix_hex1 = [tensor1_bin[i:i+8] for i in range(0, len(tensor1_bin), 8)]
    matrix_hex2 = [tensor2_bin[i:i+4] for i in range(0, len(tensor2_bin), 4)]
    cal_result_hex = hex_matrix_multiply(matrix_hex1, matrix_hex2)
    cal_result_hex = [[extract_bits(hex_value) for hex_value in row] for row in cal_result_hex]

    result_bin = [float32_to_fixed16(num.item()) for row in result for num in row]
    result_hex = [result_bin[i:i+4] for i in range(0, len(result_bin), 4)]
    print("Tensor 1:\n", tensor1)
    print("Tensor 2:\n", tensor2)
    # print("Tensor 1 Binary is:", tensor1_bin)
    print("Tensor 1 Hex is:", matrix_hex1)
    # print("Tensor 2 Binary is:", tensor2_bin)
    print("Tensor 2 Hex is:", matrix_hex2)
    print("Result of Matrix Multiplication:\n", result)
    print("Result Hex transposed from fp32 is:", result_hex)
    print("Caculated Result Hex is:", cal_result_hex)

    gelu_result = calculate_gelu(result)
    gelu_result_bin = [float32_to_fixed16(num.item()) for row in gelu_result for num in row]
    gelu_result_hex = [gelu_result_bin[i:i+4] for i in range(0, len(gelu_result_bin), 4)]
    print("Result of GELU:\n", gelu_result)
    print("GELU Result Hex transposed from fp32 is:", gelu_result_hex)

    cal_gelu_result_hex = [[relu2gelu(hex_value) for hex_value in row] for row in cal_result_hex]
    print("Caculated GELU Result Hex is:", cal_gelu_result_hex)