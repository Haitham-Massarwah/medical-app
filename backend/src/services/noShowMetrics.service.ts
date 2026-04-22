export interface BinaryMetrics {
  auc: number;
  precision: number;
  recall: number;
  f1: number;
  accuracy: number;
  confusion_matrix: {
    tp: number;
    fp: number;
    tn: number;
    fn: number;
  };
}

export class NoShowMetricsService {
  calculateAUC(labels: number[], probabilities: number[]): number {
    if (labels.length === 0 || labels.length !== probabilities.length) return 0;
    const pairs = labels.map((label, i) => ({ label, score: probabilities[i] }));
    pairs.sort((a, b) => b.score - a.score);

    const positives = labels.filter((v) => v === 1).length;
    const negatives = labels.length - positives;
    if (positives === 0 || negatives === 0) return 0.5;

    let tp = 0;
    let fp = 0;
    let prevTpr = 0;
    let prevFpr = 0;
    let auc = 0;
    for (const p of pairs) {
      if (p.label === 1) tp += 1;
      else fp += 1;
      const tpr = tp / positives;
      const fpr = fp / negatives;
      auc += (fpr - prevFpr) * (tpr + prevTpr) * 0.5;
      prevTpr = tpr;
      prevFpr = fpr;
    }
    return Number(auc.toFixed(6));
  }

  calculateConfusionMatrix(labels: number[], predictions: number[]): BinaryMetrics['confusion_matrix'] {
    let tp = 0;
    let fp = 0;
    let tn = 0;
    let fn = 0;
    for (let i = 0; i < labels.length; i += 1) {
      const y = labels[i] === 1 ? 1 : 0;
      const p = predictions[i] === 1 ? 1 : 0;
      if (y === 1 && p === 1) tp += 1;
      else if (y === 0 && p === 1) fp += 1;
      else if (y === 0 && p === 0) tn += 1;
      else fn += 1;
    }
    return { tp, fp, tn, fn };
  }

  calculatePrecision(labels: number[], predictions: number[]): number {
    const { tp, fp } = this.calculateConfusionMatrix(labels, predictions);
    return tp + fp > 0 ? Number((tp / (tp + fp)).toFixed(6)) : 0;
  }

  calculateRecall(labels: number[], predictions: number[]): number {
    const { tp, fn } = this.calculateConfusionMatrix(labels, predictions);
    return tp + fn > 0 ? Number((tp / (tp + fn)).toFixed(6)) : 0;
  }

  evaluate(labels: number[], probabilities: number[], threshold: number): BinaryMetrics {
    const predictions = probabilities.map((p) => (p >= threshold ? 1 : 0));
    const cm = this.calculateConfusionMatrix(labels, predictions);
    const precision = this.calculatePrecision(labels, predictions);
    const recall = this.calculateRecall(labels, predictions);
    const f1 = precision + recall > 0 ? Number(((2 * precision * recall) / (precision + recall)).toFixed(6)) : 0;
    const accuracy = labels.length > 0 ? Number(((cm.tp + cm.tn) / labels.length).toFixed(6)) : 0;
    const auc = this.calculateAUC(labels, probabilities);
    return { auc, precision, recall, f1, accuracy, confusion_matrix: cm };
  }
}

