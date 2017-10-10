//
//  Algorithm.m
//  iBroker
//
//  Created by Markus Bröker on 12.05.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "Algorithm.h"

@implementation Algorithm

/**
 * Datenstruktur für den Gaußschen Algorithmus
 *
 * @param equations int
 * @param data NSArray*
 */
+ (double **)gaussAlloc:(int)equations withData:(NSArray *)data {

    double **matrix = calloc(equations, sizeof(double *));

    for (int i = 0; i < equations; i++) {
        matrix[i] = calloc(equations + 1, sizeof(double));

        for (int j = 0; j < equations + 1; j++) {
            matrix[i][j] = [data[i][j] doubleValue];
        }
    }

    return matrix;
}

/**
 * Dealloc der Datenstruktur für den Gaußschen Algorithmus
 *
 * @param matrix double**
 * @param equations int
 */
+ (void)gaussDealloc:(double **)matrix withEquations:(int)equations {
    for (int i = 0; i < equations; i++) {
        if (matrix[i] != NULL) {
            free(matrix[i]);
        }
    }

    if (matrix != NULL) {
        free(matrix);
    }
}

/**
 * Cocoa/Gauß Bridge
 *
 * @param matrix double**
 * @param equations int
 *
 * @return NSArray*
 */
+ (NSArray *)gaussResult:(double **)matrix withEquations:(int)equations {

    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (int i = 0; i < equations; i++) {
        result[i] = [[NSMutableArray alloc] init];

        for (int j = 0; j < equations + 1; j++) {
            // Runde das Ergebnis auf 4 Nachkommastellen
            result[i][j] = @([Algorithm nearest:matrix[i][j] withAccuracy:4]);
        }
    }

    return result;
}

/**
 * Cocoa Version
 *
 * @param data NSArray*
 *
 * @return NSArray*
 */
+ (NSArray *)gaussAlgorithm:(NSArray *)data {
    int equations = (int) [data count];

    double **matrix = [Algorithm gaussAlloc:equations withData:data];

    [Algorithm gaussAlgorithm:matrix withEquations:equations];
    NSArray *result = [Algorithm gaussResult:matrix withEquations:equations];
    [Algorithm gaussDealloc:matrix withEquations:equations];

    return result;
}

/**
 * Löst ein linerares Gleichungssystem nxn auf
 *
 * @param matrix double**
 * @param equations int
 */
+ (void)gaussAlgorithm:(double **)A withEquations:(int)equations {

    double ACCURACY = pow(10, -3);

    int i, j, k, n;

    double h;

    int MAXX = equations + 1;
    int MAXY = equations;

    // Ohne Matrix gibts nichts zu lösen
    if (A == NULL) {
        return;
    }

    // Ohne die Anzahl der Gleichungen kann nichts gerechnet werden
    if (equations == 0) {
        return;
    }

    i = 0;
    for (j = 0; j < MAXY; j++) {
        for (k = j + 1; k < MAXY; k++) {
            if (A[k][i] != 0.0) {
                h = A[j][i] / A[k][i];
            } else {
                continue;
            }

            for (n = 0; n < MAXX; n++) {
                A[k][n] *= -h;
                A[k][n] += A[j][n];

                if ((A[k][n] < ACCURACY) && (A[k][n] > -ACCURACY)) {
                    A[k][n] = 0.0;
                }
            }
        }

        i++;
    }

    i--;

    for (j = MAXY - 1; j > -1; j--) {
        for (k = j - 1; k > -1; k--) {
            if (A[k][i] != 0.0) {
                h = A[j][i] / A[k][i];
            } else {
                h = 0.0;
            }

            for (n = MAXX - 1; n > k - 1; n--) {
                A[k][n] *= -h;
                A[k][n] += (A[j][n]);

                if (A[j][i] == 0.0) {
                    return;
                }

                A[j][n] /= (A[j][i]);
            }
        }

        i--;
    }

    if ((h = A[0][0]) == 0.0) {
        return;
    }
    /*
     * h=A[0][0];
     */
    A[0][0] /= h;
    A[0][MAXX - 1] /= h;
}

/**
 * Rounding Method for nearest and cleanest result
 *
 * @param value double
 * @param accuracy double
 * @return double
 */
+ (double)nearest:(double)value withAccuracy:(double)accuracy {
    return round(pow(10, accuracy) * value) / pow(10, accuracy);
}

@end
