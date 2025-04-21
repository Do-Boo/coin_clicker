String formatNumber(double number) {
  if (number < 1000) return number.toStringAsFixed(0);
  
  if (number < 1000000) { // Less than 1M
    return '${(number / 1000).toStringAsFixed(2)}K';
  }
  
  if (number < 1000000000) { // Less than 1B
    return '${(number / 1000000).toStringAsFixed(2)}M';
  }
  
  if (number < 1000000000000) { // Less than 1T
    return '${(number / 1000000000).toStringAsFixed(2)}B';
  }
  
  return '${(number / 1000000000000).toStringAsFixed(2)}T';
} 