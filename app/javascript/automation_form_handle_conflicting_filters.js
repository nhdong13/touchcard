const calculateValue = function(value, condition) {
  const conditionWhenValueIsDate = ['matches_date', 'before', 'after'];
  const conditionWhenValueIsNumber = ['matches_number', 'greater_number', 'smaller_number'];
  
  if (conditionWhenValueIsDate.includes(condition)) { 
    return new Date(value);
  } 
  
  if (conditionWhenValueIsNumber.includes(condition)) {
    return parseInt(value);
  } 
  
  if (condition == 'between_number') {
    return [parseInt(value.split('&')[0]), parseInt(value.split('&')[1])];
  } 
  
  if (condition == 'between_date') {
    return [new Date(value.split('&')[0]), new Date(value.split('&')[1])];
  }
}

const convertDaysAgoToDate = function(value, today = new Date()) {
  today.setUTCHours(0, 0, 0, 0);
  today.setDate(today.getDate() - value);
  return today;
}

const sameFiltersNotConflict = function() {
  let valid = true;
  // Remove all old duplicated filters and conflicting filters which have same filter type
  this.conflictFilters.forEach(item => {
    let actAppearance = this.acceptedFilters.find(ft => ft.selectedFilter == item);
    let rmvAppearance = this.removedFilters.find(ft => ft.selectedFilter == item);
    this.markInvalidFilter('accepted', actAppearance, actAppearance, true);
    this.markInvalidFilter('removed', rmvAppearance, rmvAppearance, true);
  })

  // Find current duplicated filters and conflicting filters
  this.acceptedFilters.forEach((includeFilter) => {
    let includeFilterType = includeFilter.selectedFilter;
    let includeCondition = includeFilter.selectedCondition;
    
    let appearance = this.removedFilters.find((excludeFilter) => {
      let excludeFilterType = excludeFilter.selectedFilter;
      let excludeCondition = excludeFilter.selectedCondition;

      let includeValue = calculateValue(includeFilter.value, includeCondition);
      let excludeValue = calculateValue(excludeFilter.value, excludeCondition);

      if (includeCondition == excludeCondition && includeFilterType == excludeFilterType) {
        return sameFilterTypeAndCondition(includeCondition, includeValue, excludeValue);
      } 

      if (includeFilterType == excludeFilterType) {
        return sameFilterType(excludeCondition, includeCondition, includeValue, excludeValue);
      }
    });

    if (appearance) {
      this.markInvalidFilter('accepted', includeFilter, includeFilter);
      this.markInvalidFilter('removed', appearance, appearance);
      this.conflictFilters.push(includeFilterType);
      valid = false;
    }
  });

  return valid;
}
// Check conflict of same filter type && condition
const sameFilterTypeAndCondition = function(includeCondition, includeValue, excludeValue) {
  switch (includeCondition) {
    case 'matches_date':
      return excludeValue.getTime() == includeValue.getTime();
    case 'between_date':
      return excludeValue[0] <= includeValue[0] && excludeValue[1] >= includeValue[1];
    case 'before':
      return excludeValue >= includeValue;
    case 'after':
      return excludeValue <= includeValue;
    case 'matches_number':
      return excludeValue == includeValue;
    case 'between_number':
      return excludeValue[0] <= includeValue[0] && excludeValue[1] >= includeValue[1];
    case 'greater_number':
      return excludeValue <= includeValue;
    case 'smaller_number':
      return excludeValue >= includeValue;
  } 
}
// Same filter type, different condition
const sameFilterType = function (excludeCondition, includeCondition, includeValue, excludeValue) {
  switch (includeCondition) {
    case 'matches_number':
      switch (excludeCondition) {
        case 'matches_date':
          return excludeValue.getTime() == convertDaysAgoToDate(includeValue).getTime();
        case 'between_date':
          return excludeValue[0] <= convertDaysAgoToDate(includeValue) && convertDaysAgoToDate(includeValue) <= excludeValue[1];
        case 'before':
          return excludeValue >= convertDaysAgoToDate(includeValue);
        case 'after':
          return excludeValue <= convertDaysAgoToDate(includeValue);
        case 'between_number':
          return excludeValue[0] <= includeValue && includeValue <= excludeValue[1];
        case 'greater_number':
          return excludeValue <= includeValue;
        case 'smaller_number':
          return excludeValue >= includeValue;
      }
      
    case 'between_number':
      switch (excludeCondition) {
        case 'between_date':
          return excludeValue[0] <= convertDaysAgoToDate(includeValue[1]) && convertDaysAgoToDate(includeValue[0]) <= excludeValue[1];
        case 'before':
          return excludeValue >= convertDaysAgoToDate(includeValue[0]);
        case 'after':
          return excludeValue <= convertDaysAgoToDate(includeValue[1]);
        case 'greater_number':
          return excludeValue <= includeValue[0];
        case 'smaller_number':
          return excludeValue >= includeValue[1];
      }
    
    case 'greater_number':
      if (excludeCondition == 'before') {
        return excludeValue >= convertDaysAgoToDate(includeValue);
      }
      break;
    
    case 'smaller_number':
      if (excludeCondition == 'after') {
        return excludeValue <= convertDaysAgoToDate(includeValue);
      }
      break;
    
    case 'matches_date':
      switch (excludeCondition) {
        case 'between_date':
          return excludeValue[0] <= includeValue && includeValue <= excludeValue[1];
        case 'before':
          return excludeValue >= includeValue;
        case 'after':
          return excludeValue <= includeValue;
        case 'matches_number':
          return convertDaysAgoToDate(excludeValue).getTime() == includeValue.getTime();
        case 'between_number':
          return convertDaysAgoToDate(excludeValue[0]) >= includeValue && includeValue >= convertDaysAgoToDate(excludeValue[1]);
        case 'greater_number':
          return convertDaysAgoToDate(excludeValue) >= includeValue;
        case 'smaller_number':
          return convertDaysAgoToDate(excludeValue) <= includeValue;
      }

    case 'between_date':
      switch (excludeCondition) {
        case 'before':
          return excludeValue >= includeValue[1];
        case 'after':
          return excludeValue <= includeValue[0];
        case 'between_number':
          return convertDaysAgoToDate(excludeValue[0]) >= includeValue[1] && convertDaysAgoToDate(excludeValue[1]) <= includeValue[0];
        case 'greater_number':
          return convertDaysAgoToDate(excludeValue) >= includeValue[1];
        case 'smaller_number':
          return convertDaysAgoToDate(excludeValue) <= includeValue[0];
      }
    
    case 'before':
      if (excludeCondition == 'greater_number') {
        return convertDaysAgoToDate(excludeValue) >= includeValue;
      }
      break;
    
    case 'after':
      if (excludeCondition == 'smaller_number') {
        return convertDaysAgoToDate(excludeValue) <= includeValue;
      }
      break;
  }
}

const checkConflictOrdersSpentFilters = function() {
  let hasError = false;
  unmarkInvalidBeforeCheck(this.acceptedFilters, this.removedFilters, this.markInvalidFilter);
  [this.acceptedFilters, this.removedFilters].forEach((collection, index) => {
    let lastOrderTotal = collection.find(ft=> ft.selectedFilter === 'last_order_total');
    let allOrderTotal = collection.find(ft=> ft.selectedFilter === 'all_order_total');
    if (!lastOrderTotal || !allOrderTotal) return;
    
    const returnValueToCompare = function(condition, value, isLastOrder) {
      let calculateVal = calculateValue(value, condition);
      if ((condition === 'matches_number') || 
          (isLastOrder && condition === 'greater_number') || 
          (!isLastOrder && condition === 'smaller_number')) {
        return calculateVal;
      }
      
      if (condition === 'between_number') {
        if (isLastOrder) return calculateVal[0];
        return calculateVal[1];
      }
    }
    
    let isError = returnValueToCompare(allOrderTotal.selectedCondition, allOrderTotal.value, false) <
                  returnValueToCompare(lastOrderTotal.selectedCondition, lastOrderTotal.value, true);
    
    let collectionName = index == 0 ? 'accepted':'removed';
    
    if (isError) {
      hasError = hasError || isError;
      this.markInvalidFilter(collectionName, lastOrderTotal, allOrderTotal);
    } else {
      this.markInvalidFilter(collectionName, lastOrderTotal, allOrderTotal, true);
    }
  })

  return hasError;
}

const checkConflictOrdersDateFilters = function() {
  let hasError = false;
  unmarkInvalidBeforeCheck(this.acceptedFilters, this.removedFilters, this.markInvalidFilter);
  [this.acceptedFilters, this.removedFilters].forEach((collection, index) => {
    let lastOrderDate = collection.find(ft=> ft.selectedFilter === 'last_order_date');
    let firstOrderDate = collection.find(ft=> ft.selectedFilter === 'first_order_date');
    if (!lastOrderDate || !firstOrderDate) return;

    let isError = ((lastOrderDate.selectedCondition === 'before' &&
                  firstOrderDate.selectedCondition === 'before') ||
                  (lastOrderDate.selectedCondition === 'after' &&
                  firstOrderDate.selectedCondition === 'after')) &&
                  Date.parse(lastOrderDate.value) < Date.parse(firstOrderDate.value);

    let collectionName = index == 0 ? 'accepted':'removed';
    
    if (isError) {
      hasError = hasError || isError;
      this.markInvalidFilter(collectionName, lastOrderDate, firstOrderDate);
    } else {
      this.markInvalidFilter(collectionName, lastOrderDate, firstOrderDate, true);
    }
  })

  return hasError;
}

const orderDateFiltersNotConflict = function() {
  let valid = true;
  unmarkInvalidBeforeCheck(this.acceptedFilters, this.removedFilters, this.markInvalidFilter);
  [this.acceptedFilters, this.removedFilters].forEach((collection, index) => {
    let firstOrderDate = collection.find(filter => filter.selectedFilter == 'first_order_date');
    let lastOrderDate = collection.find(filter => filter.selectedFilter == 'last_order_date');
    let collectionType = index == 0 ? 'accepted':'removed'; 
    if (!firstOrderDate || !lastOrderDate) return;

    const returnCompareValue = function(condition, value, isFirst) {
      let calculateVal = calculateValue(value, condition);
      switch (condition) {
        case isFirst ? 'after' : 'before':
        case 'matches_date':
          return calculateVal;
        case 'between_date':
          return isFirst ? calculateVal[0] : calculateVal[1];
        case 'between_number':
          return convertDaysAgoToDate(isFirst ? calculateVal[1] : calculateVal[0]);
        case 'matches_number':
        case isFirst ? 'smaller_number' : 'greater_number':
          return convertDaysAgoToDate(calculateVal);
        default:
          break;
      }
    }

    let firstCompareValue = returnCompareValue(firstOrderDate.selectedCondition, firstOrderDate.value, true);
    let lastCompareValue = returnCompareValue(lastOrderDate.selectedCondition, lastOrderDate.value, false);
    let isError = (!firstCompareValue || !lastCompareValue) ? false : lastCompareValue < firstCompareValue;
    
    if (isError) {
      this.markInvalidFilter(collectionType, firstOrderDate, lastOrderDate);
      valid = false;
    } else {
      this.markInvalidFilter(collectionType, firstOrderDate, lastOrderDate, true);
    }
  })

  return valid;
}

const unmarkInvalidBeforeCheck = function(acceptedFilters, removedFilters, markInvalidFilterfunc) {
  [acceptedFilters, removedFilters].forEach((collection, index) => {
    if (collection.lenght == 0) return;
    let collectionType = index == 0 ? 'accepted' : 'removed';
    collection.forEach(item => {
      markInvalidFilterfunc(collectionType, item, item, true);
    });
  })
}

export { sameFiltersNotConflict, checkConflictOrdersSpentFilters, checkConflictOrdersDateFilters, orderDateFiltersNotConflict }
