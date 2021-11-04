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
	const convertDaysAgoToDate = function(value, today = new Date()) {
		today.setUTCHours(0, 0, 0, 0);
		today.setDate(today.getDate() - value);
		return today;
	};

	switch (includeCondition) {
		case 'matches_number':
			switch (excludeCondition) {
				case 'matches_date':
					return excludeValue.getTime() == convertDaysAgoToDate(includeValue).getTime();
				case 'between_date':
					return excludeValue[0] <= convertDaysAgoToDate(includeValue) && convertDaysAgoToDate(includeValue) <= excludeValue[1];
				case 'before':
					return excludeValue > convertDaysAgoToDate(includeValue);
				case 'after':
					return excludeValue < convertDaysAgoToDate(includeValue);
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
					return excludeValue > convertDaysAgoToDate(includeValue[0]);
				case 'after':
					return excludeValue < convertDaysAgoToDate(includeValue[1]);
				case 'greater_number':
					return excludeValue <= includeValue[0];
				case 'smaller_number':
					return excludeValue >= includeValue[1];
			}
		
		case 'greater_number':
			if (excludeCondition == 'before') {
				return excludeValue > convertDaysAgoToDate(includeValue);
			}
			break;
		
		case 'smaller_number':
			if (excludeCondition == 'after') {
				return excludeValue < convertDaysAgoToDate(includeValue);
			}
			break;
		
		case 'matches_date':
			switch (excludeCondition) {
				case 'between_date':
					return excludeValue[0] <= includeValue && includeValue <= excludeValue[1];
				case 'before':
					return excludeValue > includeValue;
				case 'after':
					return excludeValue < includeValue;
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
				return convertDaysAgoToDate(excludeValue) > includeValue;
			}
			break;
		
		case 'after':
			if (excludeCondition == 'smaller_number') {
				return convertDaysAgoToDate(excludeValue) < includeValue;
			}
			break;
	}
}

const checkConflictOrdersSpentFilters = function() {
	let hasError = false;
	[this.acceptedFilters, this.removedFilters].forEach((collection, index) => {
		let lastOrderTotal = collection.find(ft=> ft.selectedFilter === 'last_order_total');
		let allOrderTotal = collection.find(ft=> ft.selectedFilter === 'all_order_total');
		let isError = lastOrderTotal && allOrderTotal &&
									lastOrderTotal.value !== null &&
									allOrderTotal.value !== null &&
									lastOrderTotal.selectedCondition === 'matches_number' &&
									allOrderTotal.selectedCondition === 'matches_number' &&
									lastOrderTotal.value > allOrderTotal.value;

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
	[this.acceptedFilters, this.removedFilters].forEach((collection, index) => {
		let lastOrderDate = collection.find(ft=> ft.selectedFilter === 'last_order_date');
		let firstOrderDate = collection.find(ft=> ft.selectedFilter === 'first_order_date');
		let isError = lastOrderDate && firstOrderDate &&
									lastOrderDate.value !== null &&
									firstOrderDate.value !== null &&
									((lastOrderDate.selectedCondition === 'before' &&
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

export { sameFiltersNotConflict, checkConflictOrdersSpentFilters, checkConflictOrdersDateFilters }
