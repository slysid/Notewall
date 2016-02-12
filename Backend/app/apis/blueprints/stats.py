#!/usr/bin/python

from flask import Blueprint, jsonify
from app import Configuration
from pymongo import MongoClient

stats = Blueprint('stats',__name__)


@stats.route('/health',methods=["GET"])
def health():
    client = MongoClient(Configuration['mongodb']['uri'])
    data = {"api":"OK","database":client.server_info()}
    return jsonify(data)