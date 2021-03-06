'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    deepPopulate = require('mongoose-deep-populate')(mongoose);

var ResultSchema = new Schema({
  form: { type: Schema.Types.ObjectId, ref: 'Form' },
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  user_info: {
    username: String,
    email: String
  },
  sections: Object,
  expires: {
    type: Date
  },
  status: {
    type: String,
    "default": "draft",
    enum: ['draft', 'submitted']
  },
  points: Number,
  total_points: Number,
  created: {
    type: Date,
    "default": Date.now
  },
  results: Object,
  updated: {
    type: Date,
    "default": Date.now
  },
  submitted: {
    type: Boolean,
    "default": false
  },
  certificate: {
    type: Schema.Types.ObjectId,
    ref: 'Certificate'
  },
  active: Boolean
});

ResultSchema.plugin(deepPopulate, {
  whitelist: [
    'user',
    'form.sections.fields.choices'
  ]
});

module.exports = mongoose.model('Result', ResultSchema);
