'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ResultSchema = new Schema({
  form: { type: Schema.Types.ObjectId, ref: 'Form' },
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  user_info: {
    username: String,
    email: String
  },
  points: Number,
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
  active: Boolean
});

module.exports = mongoose.model('Result', ResultSchema);
