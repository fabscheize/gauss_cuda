#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define EPS 1E-9

void generate_matrix(int n, double **matrix);
long double determinant(int n, double **matrix);

int main() {
  for (int n = 3; n < 3004; n += 200) {
    printf("\nВычисление определителя матрицы %d x %d ...", n, n);
    fflush(stdout);
    double **matrix_pointer_array = (double **)calloc(n, sizeof(double *));
    double *matrix_values_array = (double *)calloc(n * n, sizeof(double));
    for (int i = 0; i < n; i++)
      matrix_pointer_array[i] = matrix_values_array + n * i;
    generate_matrix(n, matrix_pointer_array);
    clock_t start = clock();
    determinant(n, matrix_pointer_array);
    clock_t end = clock();
    free(matrix_values_array);
    free(matrix_pointer_array);
    double cpu_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Определитель матрицы %d x %d вычислен за %lf сек\n", n, n,
           cpu_time);
  }
  return 0;
}
void generate_matrix(int n, double **matrix) {
  srand(time(NULL));
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      matrix[i][j] = rand() % 10;
    }
  }
}
long double determinant(int n, double **matrix) {
  long double det = 1.0;
  for (int i = 0; i < n; i++) {
    int m = i;
    for (int j = i + 1; j < n; j++) {
      if (fabs(matrix[j][i]) > fabs(matrix[m][i])) {
        m = j;
      }
    }
    if (fabs(matrix[m][i]) < EPS) {
      det = 0.0;
      break;
    }
    if (i != m) {
      det = -det;
      for (int l = 0; l < n; l++) {
        double temp = matrix[i][l];
        matrix[i][l] = matrix[m][l];
        matrix[m][l] = temp;
      }
    }
    det *= matrix[i][i];
    for (int j = i + 1; j < n; j++) {
      if (fabs(matrix[j][i]) > EPS) {
        for (int k = i + 1; k < n; k++) {
          matrix[j][k] -= matrix[i][k] / matrix[i][i] * matrix[j][i];
        }
      }
    }
  }
  return det;
}
