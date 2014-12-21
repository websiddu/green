'use strict';

var express = require('express');
var controller = require('./form.controller');
var auth = require('../../auth/auth.service');

var router = express.Router();

router.get('/', auth.isAuthenticated(), controller.index);
router.get('/:id', auth.isAuthenticated(), controller.show);
router.post('/', auth.isAuthenticated(), controller.create);
router.put('/:id', auth.isAuthenticated(), controller.update);
router.patch('/:id', auth.isAuthenticated(),  controller.update);
router.delete('/:id', auth.isAuthenticated(), controller.destroy);

router.put('/s/:id', auth.isAuthenticated(), controller.updatesection)
router.delete('/s/:id', auth.isAuthenticated(), controller.removesection)

module.exports = router;
