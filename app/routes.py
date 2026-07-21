from flask import jsonify, request
from app import app, db
from app.models import Employee


@app.route("/")
def home():
    return "Employee Management System"


# GET ALL EMPLOYEES
@app.route("/employees", methods=["GET"])
def get_employees():
    employees = Employee.query.all()
    return jsonify([emp.to_dict() for emp in employees])


# GET SINGLE EMPLOYEE
@app.route("/employees/<int:emp_id>", methods=["GET"])
def get_employee(emp_id):
    employee = Employee.query.get_or_404(emp_id)
    return jsonify(employee.to_dict())


# CREATE EMPLOYEE
@app.route("/employees", methods=["POST"])
def create_employee():
    data = request.get_json()

    employee = Employee(
        name=data["name"],
        email=data["email"],
        department=data["department"],
        salary=data["salary"]
    )

    db.session.add(employee)
    db.session.commit()

    return jsonify(employee.to_dict()), 201


# UPDATE EMPLOYEE
@app.route("/employees/<int:emp_id>", methods=["PUT"])
def update_employee(emp_id):
    employee = Employee.query.get_or_404(emp_id)

    data = request.get_json()

    employee.name = data.get("name", employee.name)
    employee.email = data.get("email", employee.email)
    employee.department = data.get("department", employee.department)
    employee.salary = data.get("salary", employee.salary)

    db.session.commit()

    return jsonify(employee.to_dict())


# DELETE EMPLOYEE
@app.route("/employees/<int:emp_id>", methods=["DELETE"])
def delete_employee(emp_id):
    employee = Employee.query.get_or_404(emp_id)

    db.session.delete(employee)
    db.session.commit()

    return jsonify({
        "message": "Employee deleted successfully"
    })