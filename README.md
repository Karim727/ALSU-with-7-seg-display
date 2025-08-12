## ALSU Design

<img width="280" height="327" alt="image" src="https://github.com/user-attachments/assets/4e554612-da6a-46f7-b09b-686227c22d41" />

### Inputs
| Input       | Width | Description |
|-------------|-------|-------------|
| `clk`       | 1     | Input clock |
| `rst`       | 1     | Active high asynchronous reset |
| `A`         | 3     | Input port A |
| `B`         | 3     | Input port B |
| `ein`       | 1     | Carry in bit (valid only if `FULL_ADDER` parameter is "ON") |
| `serial_in` | 1     | Serial in bit (used in shift operations only) |
| `red_op_A`  | 1     | When high, executes reduction operation on A (instead of bitwise A/B) for AND/XOR opcodes |
| `red_op_B`  | 1     | When high, executes reduction operation on B (instead of bitwise A/B) for AND/XOR opcodes |
| `opcode`    | 3     | Determines operation (see separate opcode table) |
| `bypass_A`  | 1     | When high, registers port A to output (ignores opcode) |
| `bypass_B`  | 1     | When high, registers port B to output (ignores opcode) |
| `direction` | 1     | Shift/rotation direction: left (high) or right (low) |



### Outputs

| Output | Width | Description |
|--------|-------|-------------|
| `leds` | 16    | When an invalid operation occurs, all bits blink (toggle on/off each clock cycle) as a warning. For valid operations, set to low. |
| `out`  | 6     | ALSU operation result output. |

### Parameters

| Parameter          | Default Value | Description |
|--------------------|---------------|-------------|
| `INPUT_PRIORITY`   | `A`           | Resolves conflicts when both `red_op_A`/`red_op_B` or `bypass_A`/`bypass_B` are high. Legal values: `A`, `B`. |
| `FULL_ADDER`       | `ON`          | If `ON`, `ein` input is used in addition operations. Legal values: `ON`, `OFF`. |


### Opcodes & Handling invalid cases
**Invalid cases**
1. Opcode bits are set to 110 or 111
2. red_op_A or red_op_B are set to high and the opcode is not AND or XOR operation

**Output when invalid cases occurs**
1. leds are blinking
2. out bits are set to low, but if the bypass_A or bypass_B are high then the output will take
the value of A or B depending on the parameter INPUT_PRIORITY

## Seven Segment Decoder 
<img width="430" height="242" alt="image" src="https://github.com/user-attachments/assets/a9748045-336c-414e-a660-205264fa9374" />

<img width="190" height="237" alt="image" src="https://github.com/user-attachments/assets/d5e4c2f8-863b-4c61-ad21-8cb562173cf3" />

<img width="421" height="190" alt="image" src="https://github.com/user-attachments/assets/b1e3abf1-503a-4ba5-a3d9-9c96da4c9607" />


**Theory of operation:**

- To illuminate a segment, the anode should be driven high while the cathode is driven low. However, since the
Basys 3 uses transistors to drive enough current into the common anode point, the anode enables are inverted.
Therefore, both the AN0..3 and the CA..G/DP signals are driven low when active.

- For each of the four digits to appear bright and continuously illuminated, all four digits should be driven once every
1 to 16ms, for a refresh frequency of about 1 KHz to 60Hz.

- For our design, the operation clock frequency is 100Mhz i.e. 10ns period. If 1ms duration for one digit, then the counter should be equal to 100,000 (10ns * 100,000 = 1ms).

**Output**

1. The least significant 4 bits of the internal register “out” which is the ALSU output will be
displayed on the right most digit
2. The most significant 2 bits of the internal register “out” will be displayed on the second digit
on the right
3. The 2 digits on the left will be displaying a dash in the middle of them as they are not used
4. If invalid case occurs then “E404” will be displayed on the 4 digits
   <img width="520" height="232" alt="image" src="https://github.com/user-attachments/assets/f7d2376e-1bc2-46a3-8b89-497b30ffbacc" />
