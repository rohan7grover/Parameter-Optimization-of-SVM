library(kernlab)
library(caret)

fitnessFunction <- function(k, n, e, train, test) {
  model <- ksvm(train$Alphabet ~ ., train, kernel = k, nu = n, epsilon = e, kpar = list())
  actual <- test$Alphabet
  predicted <- predict(model, test)
  accuracy <- round(mean(actual == predicted) * 100, 2)
  return(accuracy)
}

dataset <- read.table('https://archive.ics.uci.edu/ml/machine-learning-databases/letter-recognition/letter-recognition.data', sep = ',', header = FALSE)
colnames(dataset)[1] <- "Alphabet"

for (i in 2:17) {
  colnames(dataset)[i] <- paste("V", (i - 1), collapse = "", sep = "")
}

dataset$Alphabet <- factor(dataset$Alphabet)

samples <- list()
for (i in 1:10) {
  sampled_data <- dataset[sample(nrow(dataset), 5000), ]
  train_index <- createDataPartition(sampled_data$Alphabet, p = 0.7, list = FALSE)
  train_data <- sampled_data[train_index, ]
  test_data <- sampled_data[-train_index, ]
  samples[[i]] <- list(train_data = train_data, test_data = test_data)
}

bestAccuracyList <- c()
bestEpsilonList <- c()
bestKernelList <- c()
bestNuList <- c()
AccuracyList <- list()

for (i in 1:10) {
  bestAccuracy = 0
  bestKernel = ""
  bestNu = 0
  bestEpsilon = 0
  iteration = 1000
  kernelList = c('rbfdot', 'polydot', 'vanilladot', 'tanhdot', 'laplacedot', 'anovadot')
  accuracy_at_each_iteration <- c()

  for (j in 1:iteration) {
    k = sample(kernelList, 1)
    n = runif(1)
    e = runif(1)
    Accuracy = fitnessFunction(k, n, e, samples[[i]]$train_data, samples[[i]]$test_data)

    if (Accuracy > bestAccuracy) {
      bestKernel = k
      bestNu = n
      bestEpsilon = e
      bestAccuracy = Accuracy
    }
    accuracy_at_each_iteration[j] = bestAccuracy
  }
  AccuracyList[[i]] <- accuracy_at_each_iteration

  bestAccuracyList[i] <- bestAccuracy
  bestKernelList[i] <- bestKernel
  bestEpsilonList[i] <- bestEpsilon
  bestNuList[i] <- bestNu
}

sampleNumbers <- c(1:10)
results <- data.frame(Sample = sampleNumbers,
                      Fitness = bestAccuracyList,
                      bestKernel = bestKernelList,
                      bestNu = bestNuList,
                      bestEpsilon = bestEpsilonList)

maxFitnessIndex <- which.max(results$Fitness)

print(results)
plot(AccuracyList[[maxFitnessIndex]], type = 'l', col = 'blue', xlab = 'Iterations', ylab = 'Accuracy', main = 'Convergence Graph')
