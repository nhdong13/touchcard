<template>
<ul :class="containerClass">
	<li :class="pageClass">
		<a @click="prevPage()" :disabled="isTotalPageTooSmall() || isInFirstPage()">
			<font-awesome-icon icon="caret-left"/>
		</a>
	</li>
	<!-- range of pages -->
	<li v-for="page in pages" :class="[page.isSelected ? 'active' : '']">
		<a v-if="page.firstPage" @click="onClickPage(1)">1</a>
		<a v-else-if="page.lastPage" @click="onClickPage(totalPage)">{{ totalPage }}</a>
		<a v-else-if="page.breakView">{{ breakViewText }}</a>
		<a v-else @click="onClickPage(page.index)">
			{{ page.content }}
		</a>
	</li>
	<li :class="pageClass">
		<a @click="nextPage()" :disabled="isTotalPageTooSmall() || isInLastPage()">
			<font-awesome-icon icon="caret-right"/>
		</a>
	</li>
</ul>
</template>
<script type="text/javascript">
export default {
	name: "CustomePagination",
	props: {
		value: {
			type: Number,
		},
		pageRange: {
	      	type: Number,
	      	default: 5
	    },
	    totalPage: {
	      	type: Number,
	      	required: true
	    },
	    containerClass: {
	    	type: String
	    },
	    pageClass: {
	    	type: String
	    },
	    clickHandler: {
	    	type: Function,
	    	default: () => {}
	    },
	    breakViewText: {
	    	type: String,
	    	default: "..."
	    }
	},
	data: function() {
		return {
			startPage: 1,
			endPage: 1,
			innerValue: 1
		}
	},
	mounted: function() {
		this.currentPage = this.value
	},
	computed: {
		currentPage: {
			get: function() {
		    	return this.innerValue
		    },
		    set: function(newValue) {
		    	this.innerValue = newValue
		    }
		},
	    pages() {
	      const range = [];

	      let pageCount = 1
	      let newPageCount = 1
	      this.startPage = this.currentPage
	      this.endPage = this.currentPage

	      while(pageCount < this.pageRange) {
	      	if (this.endPage + 1 <= this.totalPage)
		    {
		        this.endPage++;
		        newPageCount++;
		    }
		    if(this.startPage - 1 > 0)
		    {
		        this.startPage--;
		        newPageCount++;
		    }

		    if(pageCount == newPageCount) break
		    else pageCount = newPageCount
	      }

	      for (let i = this.startPage; i <= this.endPage; i+= 1 ) {
	        range.push({
	          index: i,
	          content: i,
	          isSelected: i === this.currentPage
	        });
	      }

	      if(this.startPage > 1) {
	      	range.unshift({firstPage: true}, {breakView: true})
	      }
	      if(this.endPage < this.totalPage) {
	      	range.push({breakView: true}, {lastPage: true})
	      }

	      return range;
	    }
	},
	methods: {
		handlePageSelected(page) {
			if(this.currentPage === page) return
			this.currentPage = page
			this.clickHandler(page)
		},
		onClickFirstPage() {
			this.handlePageSelected(1)	
		},
		prevPage() {
			if(this.currentPage - this.pageRange < 1 ) return
	      	this.handlePageSelected(this.currentPage - this.pageRange);
	    },
	    onClickPage(page) {
	      this.handlePageSelected(page);
	    },
	    nextPage() {
	    	if(this.currentPage + this.pageRange > this.totalPage ) return
	      	this.handlePageSelected(this.currentPage + this.pageRange);
	    },
	    onClickLastPage() {
			this.handlePageSelected(this.totalPage)	
		},
	    isInLastPage() {
	    	return this.currentPage === this.totalPage
	    },
	    isInFirstPage() {
	    	return this.currentPage === 1	
	    },
	    isTotalPageTooSmall() {
	    	return this.totalPage <= this.pageRange
	    }
	}
}
</script>
<style type="text/css" scoped>
a {
  cursor: pointer;
}

.active {
	background-color: grey;
}
</style>