<template>
<ul :class="containerClass">
	<li :class="pageItemClass">
		<a @click="prevPage()" >
			<font-awesome-icon icon="caret-left"/>
		</a>
	</li>
	<!-- range of pages -->
	<li :class="pageItemClass">
		<a @click="nextPage()">
			<font-awesome-icon icon="caret-right"/>
		</a>
	</li>
</ul>
</template>
<script type="text/javascript">
export default {
	name: "CustomePagination"
	props: {
		currentPage: {
			type: Number,
			default: 1
		},
		pageRange: {
	      	type: Number,
	      	default: 3
	    },
	    pageCount: {
	      	type: Number,
	      	required: true
	    },
	    containerClass: {
	    	type: String
	    },
	    pageItemClass: {
	    	type: String
	    },
	    clickHandler: {
	    	type: Function,
	    	default: () => {}
	    }
	},
	computed: {

	},
	methods: {

	}
}
</script>
<style type="text/css" scoped>
a {
  cursor: pointer;
}
</style>