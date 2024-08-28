#include <cuda.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#define EPS 1E-9

__global__ void calculate_matrix(float* matrix, int n, float* det);

int main() {
  for (int n = 3; n < 3004; n += 200) {
    float* matrix = (float*)malloc(n * n * sizeof(float));
    float det = 1.0;

    srand(time(NULL));
    for (int i = 0; i < n * n; i++) matrix[i] = rand() % 10;

    float* cudaMatrix = NULL;
    float* cudadet = NULL;
    cudaMalloc(&cudaMatrix, n * n * sizeof(float));
    cudaMemcpy(cudaMatrix, matrix, n * n * sizeof(float),
               cudaMemcpyHostToDevice);
    cudaMalloc(&cudadet, sizeof(float));
    cudaMemcpy(cudadet, &det, sizeof(float), cudaMemcpyHostToDevice);
    float calculation_time = 0.0;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    calculate_matrix<<<(n + 900) / 900, 900>>>(cudaMatrix, n, cudadet);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&calculation_time, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaMemcpy(&det, cudadet, sizeof(float), cudaMemcpyDeviceToHost);

    printf("Определитель матрицы %d x %d вычислен за %lf сек\n", n, n,
           (float)(calculation_time / 1000));
    free(matrix);
    cudaFree(cudaMatrix);
  }
  return 0;
}
__global__ void calculate_matrix(float* matrix, int n, float* det) {
  int xid = blockIdx.x * blockDim.x + threadIdx.x;

  for (int i = 0; i < n; ++i) {
    int k = i;
    for (int j = i + 1; j < n; ++j) {
      if (fabs(matrix[j * n + i]) > fabs(matrix[k * n + i])) {
        k = j;
      }
    }
    if (fabs(matrix[k * n + i]) < EPS) {
      *det = 0.0;
      break;
    }
    if (i != k) {
      *det = -*det;
      for (int l = 0; l < n; l++) {
        float temp = matrix[i * n + l];
        matrix[i * n + l] = matrix[k * n + l];
        matrix[k * n + l] = temp;
      }
    }
    *det *= matrix[i * n + i];
    for (int j = i + 1; j < n; ++j) {
      if (xid < n) {
        matrix[j * n + i + xid] -=
            matrix[i * n + i + xid] * (matrix[j * n + i] / matrix[i * n + i]);
      }
    }
  }
}
