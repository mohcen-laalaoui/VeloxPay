from flask import Flask, request, jsonify
def create_flask_api(model_path):    
    app = Flask(__name__)
    monitoring_service = AnomalyMonitoringService(model_path=model_path)
    
    @app.route('/predict', methods=['POST'])
    def predict():
        try:
            data = request.json
            df = pd.DataFrame(data['data'])
            
            y_pred, anomaly_scores = monitoring_service.model.predict(df)
            
            result = {
                'predictions': y_pred.tolist(),
                'anomaly_scores': anomaly_scores.tolist(),
                'anomaly_indices': np.where(y_pred == 1)[0].tolist()
            }
            
            if np.sum(y_pred) > 0:
                explanations = monitoring_service.model.explain_predictions(df)
                result['explanations'] = {
                    str(idx): {
                        'anomaly_score': float(explanations[idx]['anomaly_score']),
                        'contributing_features': [
                            {
                                'feature': str(feature),
                                'contribution': float(contribution),
                                'value': float(value)
                            }
                            for feature, contribution, value in explanations[idx]['top_contributing_features']
                        ]
                    }
                    for idx in explanations
                }
            
            return jsonify(result)
        
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    
    @app.route('/monitor', methods=['POST'])
    def monitor():
        try:
            data = request.json
            df = pd.DataFrame(data['data'])
            
            anomalies = monitoring_service.check_data(df)
            
            result = {
                'anomalies_detected': len(anomalies),
                'anomalies': [
                    {
                        'index': anomaly['index'],
                        'anomaly_score': float(anomaly['anomaly_score']),
                        'timestamp': anomaly['timestamp']
                    }
                    for anomaly in anomalies
                ]
            }
            
            return jsonify(result)
        
        except Exception as e:
            return jsonify({'error': str(e)}), 400
    
    return app