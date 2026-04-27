
from flask import Flask, jsonify
from flask_cors import CORS
from models.db import init_db
from routes.scan_routes import scan_bp
from routes.alert_routes import alert_bp

# Initialize Flask app
app = Flask(__name__)

# Enable CORS for all routes (allows Flutter app to call the API)
CORS(app)

# Register blueprints
app.register_blueprint(scan_bp)
app.register_blueprint(alert_bp)


@app.route('/', methods=['GET'])
def index():
    """Root endpoint - API welcome message."""
    return jsonify({
        'message': 'Net-Fence AI Backend',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'scan': '/api/scan',
            'alerts': '/api/alerts'
        }
    }), 200


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok'}), 200


if __name__ == '__main__':
    # Run Flask app on port 5000
    app.run(debug=True, host='0.0.0.0', port=5000)
