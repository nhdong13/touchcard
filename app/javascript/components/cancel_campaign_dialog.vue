<template>
	<md-dialog v-bind="$attrs" v-on="$listeners" :md-fullscreen="false">
	    <md-dialog-title v-if="Title">{{ Title }}</md-dialog-title>
	    <md-dialog-content v-if="Content" class="content">{{ Content }}</md-dialog-content>

	    <div class="text-right">
	      <md-button @click="onCancel" class="bg-gray fw-bold">{{ CancelText }}</md-button>
	      <md-button class="bg-primary text-white fw-bold" @click="onConfirm">{{ ConfirmText }}</md-button>
	    </div>
  </md-dialog>
</template>
<script>
export default {
	name: "CancelCampaignDialog",
	props: {
		Title: {
			type: String
		},
		Content: {
			type: String,
			required: true
		},
		CancelText: {
			type: String,
			default: 'Cancel'
		},
		ConfirmText: {
			type: String,
			default: 'Ok'	
		}
	},
	methods: {
		onCancel: function() {
			this.$emit('onCancel')
		},
		onConfirm: function() {
			this.$emit('onConfirm')
		}
	}
}
</script>
<style lang="scss" scoped>
.content {
	font-size: 15px;
}

.bg-gray {
	background-color: #E5E7EB;
}

.bg-primary {
	background-color: #0150ee;
}

.text-right {
	text-align: right;
}

.bg-primary.text-white {
	color: white;
}

.fw-bold {
	font-weight: bold;
}
</style>